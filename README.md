# RW iOS SDK

RWFit iOS BLE SDK — 用于智能戒指/手环设备的蓝牙通信开发套件。

RWFit iOS BLE SDK — Bluetooth communication SDK for smart ring/band devices.

## 文档 / Documentation

- [中文文档](doc/blesdkios_zh.md)
- [English Documentation](doc/blesdkios_en.md)

## SDK 版本选择 / SDK Variants

请选择以下一个 `DHBleSDK.xcframework`，不要同时引入多个版本。/ Choose one variant only.

| 版本 / Variant | 文件 / Framework | 新增依赖 / Additional dependencies |
| --- | --- | --- |
| basic | [DHBleSDK.xcframework](Frameworks/DHBleSDK.xcframework) | 无 / None |
| nordic | [nordic/DHBleSDK.xcframework](Frameworks/nordic/DHBleSDK.xcframework) | `iOSMcuManagerLibrary` (SPM 1.14.7) |

无需 Nordic OTA 时选择 basic，需要 Nordic OTA 时选择 nordic。SDK 设置为 **Do Not Embed**。完整依赖配置见集成文档。

Choose basic unless Nordic OTA is required; otherwise choose nordic. Set the SDK to **Do Not Embed**. See the integration documentation for dependency setup.

Demo 使用 **nordic**。打开 `RW_SDK_DEMO/DHBleSDKDemo.xcworkspace`，等待 SPM 依赖解析完成后运行。/ The Demo uses **nordic**. Open the workspace and allow SPM dependencies to resolve before running.

## Demo 展示 / Demo Preview

<p align="center">
  <img src="doc/demo-health-data.png" alt="RW iOS SDK health data Demo" width="45%" />
  <img src="doc/demo-device-features.png" alt="RW iOS SDK device features Demo" width="45%" />
</p>

## License

[MIT License](LICENSE)
