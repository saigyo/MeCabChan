MeCabChan
=========

![Logo](https://github.com/saigyo/MeCabChan/blob/master/Logo-MeCabChan.png)

A small OSX GUI for [MeCab](https://en.wikipedia.org/wiki/MeCab) to tokenize and POS-tag Japanese sentences.

![Screenshot](https://github.com/saigyo/MeCabChan/blob/master/Screenshot-MeCabChan.png) 

Download
--------

Download the DMG of the [latest release](https://github.com/saigyo/MeCabChan/releases/latest), open it and drag
MeCabChan to your Applications folder. The app is signed and notarized and requires macOS 14 or later on Apple
silicon.

Building
--------

Requires macOS 14 or later on Apple silicon and Xcode 26.

Open `MeCabChan.xcodeproj` and build the `MeCabChan` scheme, or run:

    xcodebuild test -project MeCabChan.xcodeproj -scheme MeCabChan

The first build fetches MeCab from [taku910/mecab](https://github.com/taku910/mecab) at a pinned commit, compiles
the library into `vendor/mecab` and the IPADIC dictionary into `vendor/ipadic` (see `scripts/build-mecab.sh`).

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

License
-------

MeCabChan is licensed under the [Apache License, Version 2.0](LICENSE).

The app includes the following third-party components. Their license texts are in the [licenses](licenses) folder
and are also bundled with the app under `Contents/Resources/licenses`.

- [MeCab](https://github.com/taku910/mecab), © 2001–2008 Taku Kudo and © 2004–2008 Nippon Telegraph and Telephone
  Corporation. MeCab is available under the GPL, the LGPL or the BSD License; MeCabChan uses it under the
  [BSD License](licenses/MeCab.txt) and links it statically.
- [IPADIC](https://github.com/taku910/mecab/tree/master/mecab-ipadic), © 2000–2003 Nara Institute of Science and
  Technology, with a large portion of the dictionary entries originating from ICOT Free Software. It is distributed
  under the [IPADIC license](licenses/IPADIC.txt), without any warranty.
