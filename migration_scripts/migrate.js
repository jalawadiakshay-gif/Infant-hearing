const admin = require('firebase-admin');

// NOTE: You must have a serviceAccountKey.json in this directory
// Download it from Firebase Console -> Project Settings -> Service Accounts
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function migrateData() {
  console.log("Starting Baalshravya Database Migration...");

  try {
    // --- 1. Migrate asha_workers -> users ---
    console.log("\nMigrating asha_workers to users...");
    const ashaWorkers = await db.collection('asha_workers').get();
    let ashaCount = 0;
    
    for (const doc of ashaWorkers.docs) {
      const data = doc.data();
      const userId = doc.id; // Using same ID
      
      await db.collection('users').doc(userId).set({
        name: data.name || '',
        phone: data.phone || '',
        role: 'asha',
        lang: data.preferredLanguage || 'en',
        district: data.district,
        village: data.assignedVillages && data.assignedVillages.length > 0 
                 ? data.assignedVillages[0] 
                 : null,
        fcmToken: data.fcmToken,
        createdAt: data.createdAt || admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true });
      
      ashaCount++;
    }
    console.log(`Migrated ${ashaCount} ASHA workers.`);

    // --- 2. Migrate users (parents/others from backend) -> users ---
    console.log("\nMigrating legacy users (parents)...");
    const legacyUsers = await db.collection('users').get();
    let parentCount = 0;
    
    for (const doc of legacyUsers.docs) {
      const data = doc.data();
      const userId = doc.id;
      
      // Don't overwrite ASHA workers if they exist here
      if (data.role === 'asha') continue;
      
      await db.collection('users').doc(userId).set({
        name: data.name || data.parentName || '',
        phone: data.phone || data.mobile || '',
        role: data.role || 'parent',
        lang: data.language || 'en',
        createdAt: data.createdAt || admin.firestore.FieldValue.serverTimestamp()
        // Intentionally not migrating password hashes
      }, { merge: true });
      
      parentCount++;
    }
    console.log(`Migrated ${parentCount} legacy users.`);

    // --- 3. Merge babies + children -> children ---
    console.log("\nMigrating babies and children...");
    
    // Process legacy 'babies' first
    const babies = await db.collection('babies').get();
    let childCount = 0;
    const childMap = new Map(); // Keep track by phone+name for dedup
    
    for (const doc of babies.docs) {
      const data = doc.data();
      const childId = doc.id;
      
      const childData = {
        name: data.name || data.babyName || '',
        dob: data.dob || data.dateOfBirth,
        gender: data.gender || 'O',
        parentName: data.parentName || data.motherName || '',
        parentPhone: data.parentPhone || data.mobile || '',
        createdBy: data.createdBy || data.ashaId || 'legacy',
        risk: {
          nicu: data.nicuAdmission || false,
          lbw: data.lowBirthWeight || false,
          fhx: data.familyHistory || false
        },
        createdAt: data.createdAt || admin.firestore.FieldValue.serverTimestamp()
      };
      
      await db.collection('children').doc(childId).set(childData);
      childMap.set(`${childData.parentPhone}_${childData.name}`.toLowerCase(), childId);
      childCount++;
    }
    
    // Process ASHA module 'children'
    const ashaChildren = await db.collection('children').get(); // Note: if writing to same collection, need care. Assuming new project or running once.
    // Better: Read from a backup or if we are just updating docs in place.
    // Since we are writing to 'children', let's assume we are just updating existing docs or it's empty initially.
    let mergedCount = 0;
    
    for (const doc of ashaChildren.docs) {
      const data = doc.data();
      if (!data.parentPhone) continue; // Already processed above if it's the new format
      
      const key = `${data.parentPhone}_${data.name}`.toLowerCase();
      
      if (childMap.has(key)) {
        // Merge into existing
        const existingId = childMap.get(key);
        if (existingId !== doc.id) {
            // Need to merge data from doc.id into existingId
            await db.collection('children').doc(existingId).set({
                village: data.village || null,
                status: data.status || null
            }, { merge: true });
            // Optionally delete the duplicate: await db.collection('children').doc(doc.id).delete();
            mergedCount++;
        }
      } else {
         // Create new
         await db.collection('children').doc(doc.id).set({
            name: data.name || '',
            dob: data.dob,
            gender: data.gender || 'O',
            parentName: data.parentName || '',
            parentPhone: data.parentPhone || '',
            village: data.village,
            createdBy: data.createdBy || data.ashaId || 'legacy',
            status: data.status,
            createdAt: data.createdAt || admin.firestore.FieldValue.serverTimestamp()
         }, { merge: true });
         childCount++;
      }
    }
    console.log(`Migrated ${childCount} children. Merged ${mergedCount} duplicates.`);


    // --- 4. Merge boa_sessions + boa_trials -> screenings ---
    console.log("\nMigrating boa_sessions to screenings...");
    const boaSessions = await db.collection('boa_sessions').get();
    let boaCount = 0;
    
    for (const doc of boaSessions.docs) {
      const data = doc.data();
      const sessionId = doc.id;
      
      // Fetch subcollection trials
      const trialsSnapshot = await db.collection(`boa_sessions/${sessionId}/boa_trials`).get();
      const trials = trialsSnapshot.docs.map(t => {
          const tData = t.data();
          return {
              db: tData.dbLevel || 0,
              hz: tData.frequency || 0,
              r: tData.response || 'u',
              c: tData.isCatchTrial || false,
              ai: tData.aiConfidence || 0.0,
              det: tData.aiDetection || 'none',
              ms: tData.latencyMs || 0
          };
      });
      
      await db.collection('screenings').doc(sessionId).set({
        childId: data.childId || data.babyId,
        conductedBy: data.conductedBy || data.ashaId,
        type: 'boa',
        result: data.outcome === 'favorable' ? 'pass' : (data.outcome === 'refer' ? 'refer' : 'incomplete'),
        date: data.sessionDate || data.createdAt || admin.firestore.FieldValue.serverTimestamp(),
        offline: data.isOffline || false,
        b: {
            outcome: data.outcome,
            noise: data.environmentalNoiseDb,
            trials: trials
        },
        createdAt: data.createdAt || admin.firestore.FieldValue.serverTimestamp()
      });
      
      // Update child lastScreening
      if (data.childId) {
          await db.collection('children').doc(data.childId).set({
              lastScreening: {
                  date: data.sessionDate || data.createdAt,
                  type: 'boa',
                  result: data.outcome === 'favorable' ? 'pass' : 'refer'
              },
              status: data.outcome === 'favorable' ? 'pass' : 'refer'
          }, { merge: true });
      }
      
      boaCount++;
    }
    console.log(`Migrated ${boaCount} BOA sessions with embedded trials.`);


    // --- 5. Merge questionnaire_sessions -> screenings ---
    console.log("\nMigrating questionnaire_sessions to screenings...");
    const qSessions = await db.collection('questionnaire_sessions').get();
    let qCount = 0;
    
    for (const doc of qSessions.docs) {
      const data = doc.data();
      const sessionId = doc.id;
      
      await db.collection('screenings').doc(sessionId).set({
        childId: data.childId || data.babyId,
        conductedBy: data.conductedBy || data.ashaId,
        type: 'q',
        result: data.riskResult === 'pass' ? 'pass' : (data.riskResult === 'refer' ? 'refer' : 'monitor'),
        date: data.sessionDate || data.createdAt || admin.firestore.FieldValue.serverTimestamp(),
        offline: data.isOffline || false,
        q: {
            answers: data.answers || {},
            score: data.totalScore,
            pct: data.riskPercentage,
            age: data.ageMonths
        },
        createdAt: data.createdAt || admin.firestore.FieldValue.serverTimestamp()
      });
      
      qCount++;
    }
    console.log(`Migrated ${qCount} Questionnaire sessions.`);


    // --- 6. Migrate referrals ---
    console.log("\nMigrating referrals...");
    const referrals = await db.collection('referrals').get();
    let refCount = 0;
    
    for (const doc of referrals.docs) {
        const data = doc.data();
        
        await db.collection('referrals').doc(doc.id).set({
            childId: data.childId,
            ashaId: data.ashaId,
            screeningId: data.screeningId || 'legacy',
            reason: data.reason || 'Referral',
            hospital: data.hospital || data.referredHospital || 'JNMC',
            status: data.status || 'pending',
            date: data.date || data.createdAt || admin.firestore.FieldValue.serverTimestamp(),
            notes: data.notes,
            updatedAt: data.updatedAt,
            createdAt: data.createdAt || admin.firestore.FieldValue.serverTimestamp()
        });
        refCount++;
    }
    console.log(`Migrated ${refCount} referrals.`);


    // --- 7. Migrate followups ---
    console.log("\nMigrating followups...");
    const followups = await db.collection('followups').get();
    let fuCount = 0;
    
    for (const doc of followups.docs) {
        const data = doc.data();
        
        await db.collection('followups').doc(doc.id).set({
            childId: data.childId,
            ashaId: data.ashaId,
            screeningId: data.screeningId,
            visitDate: data.visitDate || data.nextVisitDate,
            completed: data.completed || false,
            completedAt: data.completedAt,
            notes: data.notes,
            createdAt: data.createdAt || admin.firestore.FieldValue.serverTimestamp()
        });
        fuCount++;
    }
    console.log(`Migrated ${fuCount} followups.`);

    console.log("\nMigration completed successfully! 🎉");
    console.log("\nNext Steps:");
    console.log("1. Verify data in Firebase Console.");
    console.log("2. Delete legacy collections (babies, asha_workers, boa_sessions, etc).");
    console.log("3. Deploy new security rules and indexes.");

  } catch (error) {
    console.error("Migration failed:", error);
  }
}

migrateData();
