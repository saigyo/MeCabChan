MeCabChan
=========

![Logo](https://github.com/saigyo/MeCabChan/blob/master/Logo-MeCabChan.png)

A small OSX GUI for [MeCab](https://en.wikipedia.org/wiki/MeCab) to tokenize and POS-tag Japanese sentences.

![Screenshot](https://github.com/saigyo/MeCabChan/blob/master/Screenshot-MeCabChan.png) 

Building
--------

Requires macOS 14 or later on Apple silicon and Xcode 26.

Open `MeCabChan.xcodeproj` and build the `MeCabChan` scheme, or run:

    xcodebuild test -project MeCabChan.xcodeproj -scheme MeCabChan

The first build fetches MeCab from [taku910/mecab](https://github.com/taku910/mecab) at a pinned commit and compiles
it into `vendor/mecab` (see `scripts/build-mecab.sh`).

Releases
--------

Pushing a tag like `v1.1.0` runs the release workflow. It builds the app, signs it with a Developer ID certificate,
packages it as a DMG, notarizes it and attaches it to a GitHub release. The workflow reads these secrets from the
`release` environment:

| Secret | Content |
| --- | --- |
| `MACOS_CERTIFICATE_P12_BASE64` | Developer ID Application certificate with private key, as base64-encoded `.p12` |
| `MACOS_CERTIFICATE_PASSWORD` | Password of the `.p12` file |
| `APPLE_TEAM_ID` | Apple Developer Team ID |
| `NOTARY_API_KEY_P8_BASE64` | App Store Connect API key (`.p8`), base64-encoded |
| `NOTARY_API_KEY_ID` | Key ID of the API key |
| `NOTARY_API_ISSUER_ID` | Issuer ID of the API key |
