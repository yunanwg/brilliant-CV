// Regression: cover letter for the Chinese profile. See
// regression/cv-zh/test.typ for the Heiti SC → Noto Sans CJK SC font
// override rationale (Linux baseline, Heiti SC not redistributable).

#import "/src/lib.typ": letter

#let metadata = toml("/template/profile_zh/metadata.toml")
#let metadata = (
  ..metadata,
  layout: (
    ..metadata.layout,
    fonts: (
      regular_fonts: ("Source Sans 3", "Noto Sans CJK SC"),
      header_font: "Noto Sans CJK SC",
    ),
  ),
)

#show: letter.with(
  metadata,
  date: "2026-01-15",
  recipient-name: "示例公司",
  recipient-address: [
    招聘团队 \
    上海市浦东新区世纪大道 100 号
  ],
  subject: "求职信：高级数据科学家",
)

= 尊敬的招聘经理，

这是一封用于视觉回归测试的示例求职信。本测试覆盖了 letter() 在
非拉丁字符场景下的渲染：标题（发件人姓名与地址、收件人信息、
日期、主题）、正文以及由 metadata 驱动的页脚。

我希望申请贵公司的高级数据科学家职位。

此致 \
敬礼。
