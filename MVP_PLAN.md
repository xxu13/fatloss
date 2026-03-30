# MVP 开发计划：碳循环减脂计划助手 iOS App

> 最后更新：2026-03-30
> 仓库地址：https://github.com/xxu13/fatloss
> 开发环境：Linux (CycleEngine) + macOS (Xcode/SwiftUI/SwiftData)

---

## 总体进度

| Phase | 名称 | 状态 | 开发环境 | 备注 |
|-------|------|------|----------|------|
| 0 | 项目脚手架 | 已完成 | Linux + macOS | CycleEngine Package + Xcode 项目均已创建 |
| 1 | CycleEngine 核心引擎 | 已完成 | Linux | 50 个测试全部通过，Swift 6.3 |
| 2 | SwiftData 数据层 | 待开始 | macOS | 需要 Xcode |
| 3 | SwiftUI 界面 | 待开始 | macOS | 需要 Xcode |
| 4 | 本地通知 | 待开始 | macOS | 需要 Xcode |
| 5 | 联调测试与打磨 | 待开始 | macOS | 需要 Xcode |

## 任务清单

### Phase 0: 项目脚手架 -- 已完成

- [x] 0.1 创建 CycleEngine Swift Package (`Packages/CycleEngine/`) -- 2026-03-27 Linux
- [x] 0.2 创建 Xcode 项目 fatloss（SwiftUI, SwiftData） -- 2026-03-28 macOS
  - 项目名：`fatloss`，Bundle ID：`xin.fatloss`
  - iOS Deployment Target：26.4（Xcode 默认，后续可按需降低）
- [x] 0.3 在 Xcode 中添加 CycleEngine 为本地 Package 依赖 -- 2026-03-28 macOS
  - 路径：`Packages/CycleEngine`，已在 project.pbxproj 中确认链接正常
- [x] 0.4 将 JSON 种子数据复制到 App Bundle -- 2026-03-28 macOS
  - 位置：`fatloss/Resources/Data/*.json`（foods / training_templates / meal_templates / rules）

### Phase 1: CycleEngine 核心引擎 -- 已完成

- [x] 1.1 数据模型 -- 2026-03-27 Linux
  - Food, Nutrients, FoodDatabase, EquivalentSwapGroup
  - TrainingTemplate, TrainingDayPlan, TrainingTemplateFile
  - MealTemplate, DayMealPlan, Meal, MealItem, MealTemplateFile
  - MacroTargets, UserParams, Gender
  - AdjustmentRule, RuleCondition, RuleAction, RuleLimits, GlobalConfig, RulesFile
  - 全部实现 Codable + Sendable，精确匹配 JSON 格式
- [x] 1.2 计算器 -- 2026-03-27 Linux
  - BMRCalculator（Mifflin-St Jeor 公式）
  - TDEECalculator（活动因子映射 6 级强度）
  - MacroAllocator（蛋白质/碳水/脂肪分配）
  - MealPlanGenerator（从模板生成周计划 + 逐餐/逐日宏量素计算）
  - FoodSwapCalculator（equivalentSwaps 表查询 + 按营养素直接换算）
- [x] 1.3 宏量素验算器 -- 2026-03-27 Linux
  - MacroValidator（逐食材累加验算，P/C/kcal 容差 5%，Fat 容差 10%）
  - ValidationResult（pass/fail + 逐字段偏差百分比 + summary 输出）
  - 支持单日验算和整周批量验算
- [x] 1.4 规则引擎 -- 2026-03-27 Linux
  - RulesEngine（条件评估 + 动作执行 + 按优先级排序）
  - 支持 5 种规则：体重停滞、训练乏力、年龄修正、饥饿/失眠缓解、快速减重保护
  - 支持按日类型（训练日/休息日/高碳日/低碳日等）选择性应用调整
- [x] 1.5 单元测试 -- 2026-03-27 Linux
  - **50 个测试，12 个套件，全部通过**
  - 覆盖：JSON 解码、BMR、TDEE、宏量素分配、食物营养计算、逐日(Day0-6)食谱验算、
    周热量汇总、食材互换(正向/反向/交叉/按营养素)、规则引擎(5种规则+优先级+多规则并发+调整应用)、
    边界条件(零值/未知ID/零营养素)、全链路集成(BMR->TDEE->分配->验算->训练饮食模板对齐)

### Phase 2: SwiftData 数据层 -- 待开始（需 macOS）

- [ ] 2.1 SwiftData 模型（替换 Xcode 模板的 Item.swift）
  - UserProfile（height, weight, age, gender, PRs, proteinPerKg, reminderTime）
  - DailyPlan（date, dayIndex, carbType, macroTargets, meals, isTrainingCompleted, isMealCompleted, trainingFeedback）
  - WeightRecord（date, weight, bodyFat?）
  - SwiftData 模型与 CycleEngine 模型分离，通过映射函数转换
- [ ] 2.2 种子数据加载器 SeedDataLoader
  - 从 Bundle `Resources/Data/` 加载 JSON 到内存缓存
  - 注意路径：`Bundle.main.url(forResource:withExtension:subdirectory:"Data")`
  - 后续 CDN 同步为第二阶段功能
- [ ] 2.3 DataRepository 数据仓库
  - 封装 CRUD：createProfile(), generateWeekPlan(), markTrainingComplete(), recordWeight() 等

### Phase 3: SwiftUI 界面 -- 待开始（需 macOS）

- [ ] 3.1 App 入口与导航（替换 Xcode 模板的 ContentView.swift）
  - TabView 底部导航：今日 / 周计划 / 体重 / 设置
  - 首次启动引导填写基础数据
  - 更新 fatlossApp.swift 中的 ModelContainer schema
- [ ] 3.2 用户档案页 Profile
  - 录入/编辑：身高、体重、年龄、性别、三大项 PR
  - 保存后自动触发 CycleEngine 重新计算
- [ ] 3.3 今日计划页 Today（核心页面）
  - 训练内容展示 + 标记完成 + 训练状态反馈（良好/乏力）
  - 饮食清单：食材名称 + 生重（主）+ 熟重参考（副）
  - 宏量素汇总条（P/C/F/kcal）
  - 饮食完成按钮
- [ ] 3.4 周计划页 Week
  - 7 天卡片横向滚动/列表
  - 训练名称、碳水类型标签、热量目标、完成状态
- [ ] 3.5 体重记录页 Weight
  - 手动输入体重（可选体脂率）
  - Swift Charts 折线图趋势
  - 标注每周一正式称重点
- [ ] 3.6 设置页 Settings
  - 编辑档案入口、提醒时间、关于页

### Phase 4: 本地通知 -- 待开始（需 macOS）

- [ ] 4.1 NotificationManager
  - UNUserNotificationCenter
  - 每日计划推送 + 训练前 1 小时加餐提醒
  - 用户可调整提醒时间

### Phase 5: 联调测试与打磨 -- 待开始（需 macOS）

- [ ] 5.1 CycleEngine + SwiftData + UI 全链路联调
- [ ] 5.2 验证 7 天循环计划数据准确性
- [ ] 5.3 UI 适配不同 iPhone 尺寸
- [ ] 5.4 App Icon + 启动屏

---

## 整体架构

```
+------------------------------------------+
|         SwiftUI Views (表现层)            |
+------------------------------------------+
|         ViewModels (MVVM, @Observable)    |
+------------------------------------------+
|         CycleEngine (独立 Swift Package)  |
|   BMR/TDEE计算 | 宏量素分配 | 食谱生成    |
|   宏量素验算   | 食材替换   | 规则引擎    |
+------------------------------------------+
|    SwiftData    |    JSON Seed Loader     |
|   (用户数据)    |   (食材库/模板/规则)     |
+------------------------------------------+
```

## 目录结构（当前实际）

```
/home/fatloss/                          # Git 仓库根目录
  fatloss.xcodeproj/                    # Xcode 项目文件
  fatloss/                              # App 源码目录
    fatlossApp.swift                    # App 入口（待 Phase 3 改造）
    ContentView.swift                   # Xcode 模板视图（待 Phase 3 替换）
    Item.swift                          # Xcode 模板模型（待 Phase 2 替换）
    Assets.xcassets/                    # 图片/颜色资源
    Resources/
      Data/                             # JSON 种子数据（已就位）
        foods.json                      # 8 种食材，中国食物成分表第6版
        training_templates.json         # 卧推专项 5 练计划
        meal_templates.json             # 7 天食谱模板，91kg 体重适配
        rules.json                      # 5 条动态调整规则
    Models/                             # SwiftData 模型（Phase 2 创建）
      UserProfile.swift
      DailyPlan.swift
      WeightRecord.swift
    ViewModels/                         # MVVM ViewModel（Phase 3 创建）
      TodayViewModel.swift
      ProfileViewModel.swift
      WeightViewModel.swift
    Views/                              # SwiftUI 界面（Phase 3 创建）
      Today/
      Profile/
      Weight/
      Settings/
    Services/                           # 业务服务（Phase 2 创建）
      DataRepository.swift
      SeedDataLoader.swift
      NotificationManager.swift
  fatlossTests/                         # 单元测试 target
    fatlossTests.swift
  fatlossUITests/                       # UI 测试 target
    fatlossUITests.swift
    fatlossUITestsLaunchTests.swift
  Packages/
    CycleEngine/                        # 已完成，独立 Swift Package
      Package.swift                     # swift-tools-version: 6.0, iOS 17+ / macOS 14+
      Sources/CycleEngine/
        CycleEngine.swift               # 入口：JSON 加载工厂方法
        Models/
          Food.swift                    # Food, Nutrients, FoodDatabase, EquivalentSwap*
          TrainingTemplate.swift        # TrainingTemplate, TrainingDayPlan, Intensity, CarbType
          MealTemplate.swift            # MealTemplate, DayMealPlan, Meal, MealItem, MealType
          MacroTargets.swift            # MacroTargets 值对象
          UserParams.swift              # UserParams, Gender
        Calculators/
          BMRCalculator.swift           # Mifflin-St Jeor
          TDEECalculator.swift          # 活动因子 x BMR
          MacroAllocator.swift          # P/C/F 分配
          MealPlanGenerator.swift       # 周计划生成 + 宏量素计算
          FoodSwapCalculator.swift      # 食材互换
        Validator/
          MacroValidator.swift          # 宏量素验算
        RulesEngine/
          AdjustmentRule.swift          # 规则数据模型
          RulesEngine.swift             # 条件评估 + 调整执行
      Tests/CycleEngineTests/
        CycleEngineTests.swift          # 50 个测试，12 个套件
        TestData/                       # 测试用 JSON 数据副本
  cycleplan.md                          # 碳循环饮食计划原始文档
  description.md                        # 项目架构设计文档
  MVP_PLAN.md                           # 本文件：进度管理
  README.md                             # 项目说明
```

## Xcode 项目信息

| 项目 | 值 |
|------|-----|
| 项目名 | fatloss |
| Bundle ID | xin.fatloss |
| iOS Deployment Target | 26.4 |
| Swift Version | 5.0 (Xcode 项目) / 6.0 (CycleEngine Package) |
| CycleEngine 依赖 | 本地 Package，路径 `Packages/CycleEngine`，已确认链接正常 |
| 测试 Targets | fatlossTests + fatlossUITests |

## 关键技术决策

- **CycleEngine 作为独立 Swift Package**：与 App 解耦，可独立测试，未来跨平台移植
- **SwiftData 模型与引擎模型分离**：避免计算逻辑依赖持久化框架
- **JSON 种子数据内嵌 Bundle**：MVP 阶段不依赖网络，完全离线可用
- **MVVM + @Observable**：iOS 17 原生状态管理，无第三方依赖

## 开发环境

| 环境 | 用途 | 当前状态 |
|------|------|----------|
| Linux (Ubuntu 24.04, Swift 6.3) | CycleEngine 开发 + 测试 | 已配置，Phase 1 已完成 |
| macOS + Xcode | Xcode 项目 + SwiftUI + SwiftData | 已配置，Phase 0 已完成 |
| Apple Developer 账号 | 真机测试 + App Store 上架 | 待注册 |

## Git 提交历史

```
c11c43f 添加 README：项目介绍、技术栈、碳循环逻辑、CycleEngine 说明和快速开始指南
ab8c809 更新 MVP_PLAN.md：标记 Phase 1 已完成，补充详细进度和跨设备接续指南
be290ac 实现 CycleEngine 核心引擎（Phase 1 完成）
86df59e 添加 MVP 开发计划：CycleEngine + SwiftUI 全阶段任务清单
43d8f32 初始化项目：碳循环减脂计划助手架构与数据
```

## Phase 2 开始前的准备工作

1. 删除 Xcode 模板文件 `Item.swift`，替换为 SwiftData 模型
2. 替换 `ContentView.swift` 为 TabView 导航结构
3. 更新 `fatlossApp.swift` 中的 ModelContainer schema
4. 在 `fatloss/` 下创建 `Models/`、`ViewModels/`、`Views/`、`Services/` 子目录
5. 在 Xcode 中将新目录和文件添加到 project target
