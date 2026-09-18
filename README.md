# Biometrics lab

An iOS teaching application that demonstrates controlled entry to local
content and saving a message in the app sandbox.

## Requirements

- Xcode 27 or newer on Apple silicon;
- iOS 17 or newer;
- an enrolled Face ID or Touch ID device for physical-device validation.

Open `lab.ios.Biometrics.xcodeproj` and run the `lab.ios.Biometrics` scheme.
The XCTest target covers deterministic application behavior in a Simulator;
complete the biometric-prompt acceptance checks on an enrolled device.

The repository uses `master.challenge` for the hands-on starting point and
`master.solution` for the post-exercise reference implementation. Detailed
challenge and solution design is intentionally kept out of this client README.
