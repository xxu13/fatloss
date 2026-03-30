# FatLoss - 碳循环减脂计划助手

一款基于碳循环饮食法的 iOS 减脂计划管理应用。根据用户体重和训练节奏，自动生成 7 天碳循环饮食方案，精确到每餐食材克数，支持宏量素验算、食材互换和动态调整。

## 核心功能

- **碳循环计划生成** -- 根据训练强度自动分配高碳/中碳/低碳日，匹配每日宏量素目标
- **精确营养计算** -- 基于《中国食物成分表》第6版，逐食材累加验算，蛋白质/碳水/热量偏差 <= 5%
- **食材一键互换** -- 等蛋白/等碳水互换（鸡胸肉 <-> 瘦牛肉 <-> 鱼肉，大米 <-> 面粉），自动重算克数
- **动态调整规则** -- 体重停滞自动降热量、训练乏力自动加碳水、减重过快自动保护
- **生重/熟重换算** -- 每种食材标注干湿比，同时显示称量用生重和参考熟重
- **本地优先架构** -- 用户数据全部存储在设备本地，零服务器依赖，完全离线可用

## 技术栈

| 层级 | 技术 | 说明 |
|------|------|------|
| UI | SwiftUI + iOS 17 | 原生界面，MVVM + @Observable |
| 计算引擎 | CycleEngine (Swift Package) | 独立模块，零 UI 依赖，可跨平台 |
| 数据持久化 | SwiftData | 用户档案、每日计划、体重记录 |
| 数据可视化 | Swift Charts | 体重趋势折线图 |
| 通知 | UNUserNotificationCenter | 每日计划推送、训练前加餐提醒 |
| 数据源 | 静态 JSON (Bundle/CDN) | 食材库、训练模板、食谱模板、调整规则 |

## 项目结构

```
fatloss/
  Packages/CycleEngine/          # 核心计算引擎（独立 Swift Package，已完成）
    Sources/CycleEngine/
      Models/                    # 数据模型（Food, TrainingTemplate, MealTemplate 等）
      Calculators/               # BMR, TDEE, 宏量素分配, 食谱生成, 食材互换
      Validator/                 # 宏量素验算器
      RulesEngine/               # 动态调整规则引擎
    Tests/CycleEngineTests/      # 50 个单元测试，12 个套件
  FatLoss/                       # iOS App（Xcode 项目，开发中）
  data/                          # 源数据 JSON
    foods.json                   # 食材库（8 种食材，含完整营养素）
    training_templates.json      # 训练计划模板
    meal_templates.json          # 7 天食谱模板
    rules.json                   # 5 条动态调整规则
  description.md                 # 架构设计文档
  cycleplan.md                   # 碳循环饮食计划原始方案
  MVP_PLAN.md                    # 开发进度管理
```

## CycleEngine 核心引擎

CycleEngine 是整个应用的计算核心，设计为独立的 Swift Package，不依赖任何 Apple UI 框架，可在 Linux/macOS 上编译和测试。

### 模块

| 模块 | 功能 |
|------|------|
| BMRCalculator | 基础代谢率（Mifflin-St Jeor 公式） |
| TDEECalculator | 每日总能量消耗（6 级训练强度映射） |
| MacroAllocator | 蛋白质/碳水/脂肪目标分配 |
| MealPlanGenerator | 从模板生成周计划，逐餐计算实际宏量素 |
| FoodSwapCalculator | 食材等量互换（等蛋白、等碳水） |
| MacroValidator | 食谱宏量素验算（目标 vs 实际偏差检查） |
| RulesEngine | 动态调整规则（5 种规则，按优先级执行） |

### 在 Linux 上构建和测试

```bash
cd Packages/CycleEngine
swift build
swift test
```

### 测试覆盖

50 个测试，12 个套件，覆盖：

- JSON 数据解码（foods / training / meal / rules）
- BMR / TDEE 计算精度
- 宏量素分配（7 种碳水系数）
- 逐日食谱验算（Day0 - Day6，偏差 <= 5%）
- 周热量汇总验算
- 食材互换（正向/反向/交叉/按营养素）
- 规则引擎（5 种规则触发/不触发/优先级/多规则并发/调整应用）
- 边界条件（零值、未知食物 ID、零营养素互换）
- 全链路集成（BMR -> TDEE -> 分配 -> 生成 -> 验算）

## 碳循环逻辑

基于 7 天训练周期，每天根据训练强度分配不同碳水系数：

| 日 | 训练内容 | 碳水类型 | 碳水系数 | 热量目标 |
|----|----------|----------|----------|----------|
| Day1 | 胸肌力量日 | 次高碳 | 4.0 | 3000 kcal |
| Day2 | 背部+二头 | 中碳 | 3.0 | 2700 kcal |
| Day3 | 卧推 12reps | 次低碳 | 2.0 | 2500 kcal |
| Day4 | 下肢+腹部 | 高碳 | 4.5 | 3200 kcal |
| Day5 | 胸肌爆发力 | 次高碳 | 3.5 | 2850 kcal |
| Day6 | 休息 | 低碳 | 0.9 | 2300 kcal |
| Day7 | 休息 | 低碳 | 0.9 | 2300 kcal |

蛋白质固定 2.2g/kg 体重，脂肪由剩余热量反推。以 91kg 体重为基准，周总热量约 18850 kcal。

## 开发环境

- **CycleEngine 开发**：Linux (Ubuntu 24.04) 或 macOS，Swift 6.0+
- **iOS App 开发**：macOS 14+ (Sonoma)，Xcode 15+
- **最低部署目标**：iOS 17
- **真机测试/上架**：Apple Developer 账号

## 开发进度

详见 [MVP_PLAN.md](MVP_PLAN.md)

| Phase | 内容 | 状态 |
|-------|------|------|
| 0 | 项目脚手架 | 部分完成 |
| 1 | CycleEngine 核心引擎 | 已完成 |
| 2 | SwiftData 数据层 | 待开始 |
| 3 | SwiftUI 界面 | 待开始 |
| 4 | 本地通知 | 待开始 |
| 5 | 联调测试与打磨 | 待开始 |

## 快速开始

```bash
# 克隆仓库
git clone git@github.com:xxu13/fatloss.git
cd fatloss

# 运行 CycleEngine 测试（Linux 或 macOS）
cd Packages/CycleEngine
swift test

# iOS App 开发（需 macOS + Xcode）
# 1. 用 Xcode 创建 FatLoss 项目
# 2. 添加 Packages/CycleEngine 为本地 Package 依赖
# 3. 复制 data/*.json 到 FatLoss/Resources/
```

## License

Private repository. All rights reserved.
