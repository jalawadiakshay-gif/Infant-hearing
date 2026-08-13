import { initializeApp } from "firebase/app";
import { getAuth, createUserWithEmailAndPassword } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyCSt4OyeV0IzPI35ulQ5cQhn1SU_T4DOA0",
  authDomain: "infant-hearing-app.firebaseapp.com",
  projectId: "infant-hearing-app",
  storageBucket: "infant-hearing-app.firebasestorage.app",
  messagingSenderId: "561253836819",
  appId: "1:561253836819:web:e010d24be502513ceb37e6"
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

createUserWithEmailAndPassword(auth, "akshayjalawadi@gmail.com", "Admin@123")
  .then((userCredential) => {
    console.log("Success! User created:", userCredential.user.email);
    console.log("You can now log in with Password: Admin@123");
    process.exit(0);
  })
  .catch((error) => {
    console.error("Error creating user:", error.message);
    process.exit(1);
  });
