[English](./README.md) | 简体中文

# Tencent Chat SDK

[![GitHub Stars](https://img.shields.io/github/stars/TencentCloud/TIMSDK?style=flat-square&logo=github)](https://github.com/TencentCloud/TIMSDK/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/TencentCloud/TIMSDK?style=flat-square&logo=github)](https://github.com/TencentCloud/TIMSDK/network/members)

Tencent Chat SDK 提供强大的 **Chat API**、**消息 SDK** 和 **UIKit** 组件，帮助开发者构建全功能实时通信——包括**单聊**、**频道聊天**、**消息推送**、**离线推送通知**等能力——覆盖 **Android、iOS、MAC、Windows、Web、Flutter、React Native** 等主流平台。

## 关于

Tencent Chat SDK 每日承载数十亿条消息，植根于腾讯生态。接入预置 **UIKit**，10 分钟内上线完整聊天体验；或选用 **Core SDK**，在经过大规模验证的消息基础设施之上构建专属 UI——全平台覆盖。

<table style="text-align:center; vertical-align:middle; width:440px">
  <tr>
    <th style="text-align:center;" width="220px">Android 体验版</th>
    <th style="text-align:center;" width="220px">iOS 体验版</th>
  </tr>
  <tr>
    <td><img style="width:200px" src="https://qcloudimg.tencent-cloud.cn/raw/078fbb462abd2253e4732487cad8a66d.png"/></td>
    <td><img style="width:200px" src="https://qcloudimg.tencent-cloud.cn/raw/b1ea5318e1cfce38e4ef6249de7a4106.png"/></td>
  </tr>
</table>

TUIKit 提供开箱即用的会话列表、消息气泡、表情回应、群组管理等组件——完全可定制、开源、生产可用。

<img src="https://qcloudimg.tencent-cloud.cn/raw/9c893f1a9c6368c82d44586907d5293d.png" style="zoom:50%;"/>

## 核心能力

- **UIKit** — 使用 UIKit 组件，10 分钟内构建功能完备的聊天应用
- **多种消息类型** — 支持文本、图片、语音、视频等多种消息类型
- **消息状态与在线感知** — 实时已读回执、在线/离线状态展示、正在输入提示，打造沉浸式聊天体验
- **通知推送** — 及时通知用户应用消息，提升转化率
- **频道管理** — 创建频道、管理成员、自定义频道资料
- **会话管理** — 查看未读消息、最近会话、置顶、删除等会话信息
- **大型社群** — 支持最多 100 万人社群，具备话题分层管理，适用于粉丝群、兴趣社区、大型活动等场景
- **高级功能** — 云端消息搜索、实时文本翻译、公众号等企业级能力

## 快速开始

这是 Tencent Chat SDK 的中枢仓库，请选择你的平台找到对应的独立仓库和集成文档。


### UIKit — 平台导航

| 平台 | 仓库 | 集成文档 |
|---|---|---|
| Android (View) | [TIMSDK / Android TUIKit](https://github.com/TencentCloud/TIMSDK/tree/master/Android/TUIKit) | [Android（View）集成文档](https://cloud.tencent.com/document/product/269/37059) |
| Android (Compose) | [TUIKit_Android_Compose](https://github.com/Tencent-RTC/TUIKit_Android_Compose) | [Android（Compose）集成文档](https://cloud.tencent.com/document/product/269/125127) |
| iOS (UIKit) | [Chat_UIKit](https://github.com/Tencent-RTC/Chat_UIKit) | [iOS（UIKit）集成文档](https://cloud.tencent.com/document/product/269/37060) |
| iOS (SwiftUI) | [TUIKit_iOS_SwiftUI](https://github.com/Tencent-RTC/TUIKit_iOS_SwiftUI) | [iOS（SwiftUI）集成文档](https://cloud.tencent.com/document/product/269/124935) |
| Web (React) | [chat-uikit-react](https://github.com/TencentCloud/chat-uikit-react) | [React UIKit 集成文档](https://cloud.tencent.com/document/product/269/83749) |
| Web (Vue) | [chat-uikit-vue](https://github.com/TencentCloud/chat-uikit-vue) | [Vue UIKit 集成文档](https://cloud.tencent.com/document/product/269/123108) |
| Flutter | [TUIKit_Flutter](https://github.com/Tencent-RTC/TUIKit_Flutter) | [Flutter UIKit 集成文档](https://cloud.tencent.com/document/product/269/70747) |
| React Native | [chat-demo-react-native](https://github.com/TencentCloud/chat-demo-react-native) | [React Native 集成文档](https://cloud.tencent.com/document/product/269/92670) |

### Core SDK — 平台导航

| 平台 | 仓库 | 集成文档 |
|---|---|---|
| Android | [chat-uikit-android](https://github.com/TencentCloud/chat-uikit-android/tree/main/ChatSDK) | [Android SDK 集成](https://cloud.tencent.com/document/product/269/75283) |
| iOS | [chat-uikit-ios](https://github.com/TencentCloud/chat-uikit-ios/tree/main/ChatSDK) | [iOS SDK 集成](https://cloud.tencent.com/document/product/269/75284) |
| Mac | [TIMSDK / Mac](https://github.com/TencentCloud/TIMSDK/blob/master/Mac/IMSDK/README_CHAT.md) | [Mac SDK 集成](https://cloud.tencent.com/document/product/269/75288) |
| Windows | [TIMSDK / Windows](https://github.com/TencentCloud/TIMSDK/tree/master/Windows/IMSDK) | [Windows SDK 集成](https://cloud.tencent.com/document/product/269/75287) |
| Flutter | [pub: tencent_cloud_chat_sdk](https://pub.dev/packages/tencent_cloud_chat_sdk) | [Flutter SDK 集成](https://cloud.tencent.com/document/product/269/96058) |
| React Native | [npm: @tencentcloud/chat](https://www.npmjs.com/package/@tencentcloud/chat) | [React Native SDK 集成](https://cloud.tencent.com/document/product/269/77536) |
| Web (JS) | [npm: @tencentcloud/chat](https://www.npmjs.com/package/@tencentcloud/chat) | [JavaScript SDK 集成](https://cloud.tencent.com/document/product/269/75286) |

## 场景方案

基于 Tencent Chat SDK 构建行业解决方案：

- 💬 [Official Channel](https://trtc.io/document/69925) — 类 WhatsApp Channel 的品牌广播与订阅能力
- 🎮 [Discord 式社区](https://trtc.io/document/53499) — 服务器、频道、话题子区、表情回应，构建大型社群
- 🤖 [AI 聊天机器人](https://trtc.io/document/54925) — 结合大语言模型，构建智能客服、情感陪伴等 AI 对话场景
- 🧧 [红包](https://trtc.io/document/78288) — 基于自定义消息与支付系统集成，在单聊和群聊中发送红包

## 快速链接

- 🤖 [AI 能力接入](https://trtc.io/document/72277) — 为聊天体验集成 AI 能力
- 🎮 [在线 Demo](https://trtc.io/demo/homepage/#/detail?scene=messenger) — 在浏览器中体验 Tencent Chat SDK
- 📡 [REST API 文档](https://trtc.io/document/34620?product=chat&menulabel=restfulapi) — 用户管理、消息收发等服务端 API
- 🏠 [产品主页](https://trtc.io/products/chat) — 功能概览、定价及企业版特性
- 🖥️ [控制台](https://console.trtc.io) — 管理应用及监控用量
- 🔄 [Chat SDK V2 API 升级指南](https://docs.qq.com/sheet/DS3lMdHpoRmpWSEFW)

## 联系我们

- **Stack Overflow**：使用标签 [`trtc.io`](https://stackoverflow.com/questions/tagged/trtc.io) 提问
- **Telegram**：[加入开发者社区](https://t.me/+EPk6TMZEZMM5OGY1)
- **WhatsApp**：[联系我们的团队](https://chat.whatsapp.com/Gfbxk7rQBqc8Rz4pzzP27A)
- **GitHub Issues**：[提交 Bug 或功能建议](https://github.com/TencentCloud/TIMSDK/issues)
