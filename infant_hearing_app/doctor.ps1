# Run Flutter doctor (works even when flutter is not on PATH)
$env:Path = "E:\flutter\bin;" + $env:Path
& "E:\flutter\bin\flutter.bat" doctor @args
