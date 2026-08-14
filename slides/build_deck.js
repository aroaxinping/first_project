const pptxgen = require("pptxgenjs");

// ---- Palette: "burdeos granate" — Credit Crunchers brand -----------------
const BURGUNDY = "6B0E1A";      // primary — dominant, ~65%
const BURGUNDY_DARK = "4A0912"; // darker shade for depth on dark slides
const CREAM = "FFFFFF";         // secondary — white, not cream (per style rule)
const GOLD = "C9A24B";          // accent — used sparingly
const INK = "2B1210";           // near-black warm charcoal for body text
const MUTED = "8A6E6E";         // muted burgundy-grey for captions

const FONT_HEAD = "Cambria";
const FONT_BODY = "Calibri";

function freshShadow() {
  return { type: "outer", color: "2B1210", opacity: 0.25, blur: 6, offset: 3, angle: 90 };
}

function numberBadge(slide, x, y, n) {
  slide.addShape("ellipse", {
    x, y, w: 0.7, h: 0.7,
    fill: { color: BURGUNDY },
    line: { type: "none" },
  });
  slide.addText(String(n), {
    x, y, w: 0.7, h: 0.7,
    align: "center", valign: "middle",
    fontFace: FONT_HEAD, fontSize: 24, bold: true, color: GOLD,
    margin: 0,
  });
}

function footer(slide, pageNum) {
  slide.addText("CREDIT CRUNCHERS  ·  HOME CREDIT DEFAULT RISK", {
    x: 0.5, y: 7.12, w: 8, h: 0.3,
    fontFace: FONT_BODY, fontSize: 9, color: MUTED, charSpacing: 1,
    margin: 0,
  });
  slide.addText(String(pageNum), {
    x: 12.5, y: 7.12, w: 0.5, h: 0.3,
    align: "right",
    fontFace: FONT_BODY, fontSize: 9, color: MUTED,
    margin: 0,
  });
}

function questionSlide(pres, opts) {
  const {
    pageNum, owner, status, question, statValue, statLabel,
    findingLines, contextLine,
  } = opts;

  const slide = pres.addSlide();
  slide.background = { color: CREAM };

  // Owner + status tag, top right
  slide.addText(owner.toUpperCase(), {
    x: 9.6, y: 0.55, w: 3.2, h: 0.35,
    align: "right",
    fontFace: FONT_BODY, fontSize: 11, bold: true, color: BURGUNDY, charSpacing: 1,
    margin: 0,
  });
  slide.addShape("roundRect", {
    x: 11.5, y: 0.95, w: 1.3, h: 0.34,
    rectRadius: 0.17,
    fill: { color: status === "Done" ? BURGUNDY : "EDE3E0" },
    line: { type: "none" },
  });
  slide.addText(status.toUpperCase(), {
    x: 11.5, y: 0.95, w: 1.3, h: 0.34,
    align: "center", valign: "middle",
    fontFace: FONT_BODY, fontSize: 9.5, bold: true,
    color: status === "Done" ? CREAM : MUTED, charSpacing: 1,
    margin: 0,
  });

  // Numbered badge + question title
  numberBadge(slide, 0.6, 0.55, pageNum - 2); // slides 3-7 -> Q1-Q5
  slide.addText(question, {
    x: 1.5, y: 0.5, w: 9.7, h: 0.85,
    fontFace: FONT_HEAD, fontSize: 25, bold: true, color: INK,
    valign: "middle",
    margin: 0,
  });

  // Big stat callout, left column
  slide.addShape("roundRect", {
    x: 0.6, y: 1.75, w: 4.2, h: 4.55,
    rectRadius: 0.12,
    fill: { color: BURGUNDY },
    line: { type: "none" },
    shadow: freshShadow(),
  });
  slide.addText(statValue, {
    x: 0.6, y: 2.55, w: 4.2, h: 1.5,
    align: "center", valign: "middle",
    fontFace: FONT_HEAD, fontSize: statValue.length > 6 ? 50 : 66, bold: true, color: GOLD,
    margin: 0,
  });
  slide.addText(statLabel, {
    x: 1.0, y: 4.05, w: 3.4, h: 1.9,
    align: "center", valign: "top",
    fontFace: FONT_BODY, fontSize: 13, color: CREAM,
    margin: 0,
  });

  // Findings, right column
  const findingsBox = 5.15;
  slide.addText("WHAT WE FOUND", {
    x: findingsBox, y: 1.85, w: 7.6, h: 0.35,
    fontFace: FONT_BODY, fontSize: 11, bold: true, color: MUTED, charSpacing: 1.5,
    margin: 0,
  });

  if (opts.chart) {
    slide.addText(opts.chart.headline, {
      x: findingsBox, y: 2.22, w: 7.6, h: 0.55,
      fontFace: FONT_BODY, fontSize: 14, color: INK,
      valign: "top", margin: 0, lineSpacingMultiple: 1.2,
    });
    slide.addChart(pres.ChartType.bar, [
      {
        name: opts.chart.seriesName,
        labels: opts.chart.labels,
        values: opts.chart.values,
      },
    ], {
      x: findingsBox, y: 2.85, w: 7.6, h: 2.55,
      barDir: opts.chart.barDir,
      chartColors: opts.chart.colors,
      showLegend: false,
      showTitle: false,
      showValue: true,
      dataLabelFormatCode: '0.00"%"',
      dataLabelColor: INK,
      dataLabelFontSize: 10.5,
      dataLabelPosition: "outEnd",
      catAxisLabelColor: MUTED,
      catAxisLabelFontSize: 10,
      valAxisHidden: true,
      valGridLine: { style: "none" },
      catGridLine: { style: "none" },
      barGapWidthPct: 35,
    });
  } else {
    const bullets = findingLines.map((t, i) => ({
      text: t,
      options: {
        bullet: { code: "25AA", color: GOLD },
        color: INK, fontFace: FONT_BODY, fontSize: 15,
        breakLine: i < findingLines.length - 1,
        paraSpaceAfter: 12,
      },
    }));
    slide.addText(bullets, {
      x: findingsBox, y: 2.3, w: 7.6, h: 3.0,
      valign: "top", margin: 0,
    });
  }

  // Context line
  slide.addShape("roundRect", {
    x: findingsBox, y: 5.55, w: 7.6, h: 0.75,
    rectRadius: 0.1,
    fill: { color: "F5EDEC" },
    line: { type: "none" },
  });
  slide.addText(contextLine, {
    x: findingsBox + 0.3, y: 5.55, w: 7.0, h: 0.75,
    valign: "middle",
    fontFace: FONT_BODY, italic: true, fontSize: 12.5, color: BURGUNDY,
    margin: 0,
  });

  footer(slide, pageNum);
  return slide;
}

async function main() {
  const pres = new pptxgen();
  pres.layout = "LAYOUT_WIDE"; // 13.3 x 7.5 in

  // ---- Slide 1: Title -------------------------------------------------
  {
    const slide = pres.addSlide();
    slide.background = { color: BURGUNDY_DARK };

    slide.addShape("ellipse", {
      x: 10.6, y: -2.2, w: 6, h: 6,
      fill: { color: BURGUNDY, transparency: 40 },
      line: { type: "none" },
    });
    slide.addShape("ellipse", {
      x: -2.5, y: 4.8, w: 5, h: 5,
      fill: { color: BURGUNDY, transparency: 55 },
      line: { type: "none" },
    });

    slide.addText("CREDIT CRUNCHERS", {
      x: 0.9, y: 2.55, w: 11, h: 0.55,
      fontFace: FONT_BODY, fontSize: 15, bold: true, color: GOLD, charSpacing: 3,
      margin: 0,
    });
    slide.addText("Home Credit Default Risk", {
      x: 0.85, y: 3.05, w: 11.5, h: 1.3,
      fontFace: FONT_HEAD, fontSize: 46, bold: true, color: CREAM,
      margin: 0,
    });
    slide.addText("Turning red-flag applicants into green-lit decisions", {
      x: 0.9, y: 4.15, w: 10, h: 0.6,
      fontFace: FONT_BODY, italic: true, fontSize: 17, color: "E3C9C3",
      margin: 0,
    });

    slide.addText("Aroa  ·  Carla  ·  Paul", {
      x: 0.9, y: 6.55, w: 6, h: 0.4,
      fontFace: FONT_BODY, fontSize: 12, color: MUTED, charSpacing: 1,
      margin: 0,
    });
  }

  // ---- Slide 2: Context / business problem ----------------------------
  {
    const slide = pres.addSlide();
    slide.background = { color: CREAM };

    slide.addText("The Business Problem", {
      x: 0.6, y: 0.55, w: 10, h: 0.7,
      fontFace: FONT_HEAD, fontSize: 32, bold: true, color: INK,
      margin: 0,
    });

    slide.addShape("roundRect", {
      x: 0.6, y: 1.65, w: 5.9, h: 4.7,
      rectRadius: 0.12,
      fill: { color: "F5EDEC" },
      line: { type: "none" },
    });
    slide.addText("WHO WE ARE", {
      x: 1.0, y: 1.95, w: 5.1, h: 0.35,
      fontFace: FONT_BODY, fontSize: 11, bold: true, color: BURGUNDY, charSpacing: 1.5,
      margin: 0,
    });
    slide.addText(
      "Credit Crunchers is a data analytics consultancy specialized in banking and consumer credit risk. This engagement simulates being brought in by a consumer credit lender serving clients with little or no formal banking history.",
      {
        x: 1.0, y: 2.35, w: 5.1, h: 1.7,
        fontFace: FONT_BODY, fontSize: 14, color: INK,
        valign: "top", margin: 0,
        lineSpacingMultiple: 1.25,
      }
    );
    slide.addText("THE ASK", {
      x: 1.0, y: 4.15, w: 5.1, h: 0.35,
      fontFace: FONT_BODY, fontSize: 11, bold: true, color: BURGUNDY, charSpacing: 1.5,
      margin: 0,
    });
    slide.addText(
      "Help the lender understand default risk to decide who to lend to, on what terms, and which products to grow or restrict.",
      {
        x: 1.0, y: 4.55, w: 5.1, h: 1.6,
        fontFace: FONT_BODY, fontSize: 14, color: INK,
        valign: "top", margin: 0,
        lineSpacingMultiple: 1.25,
      }
    );

    slide.addShape("roundRect", {
      x: 6.8, y: 1.65, w: 5.9, h: 4.7,
      rectRadius: 0.12,
      fill: { color: BURGUNDY },
      line: { type: "none" },
      shadow: freshShadow(),
    });
    slide.addText("THE DATA", {
      x: 7.2, y: 1.95, w: 5.1, h: 0.35,
      fontFace: FONT_BODY, fontSize: 11, bold: true, color: GOLD, charSpacing: 1.5,
      margin: 0,
    });
    const dataPoints = [
      { text: "application — one row per applicant, 307,493 cleaned records", options: { bullet: { code: "25AA", color: GOLD }, breakLine: true, paraSpaceAfter: 14 } },
      { text: "bureau — prior credit history at other institutions, 1,465,248 records", options: { bullet: { code: "25AA", color: GOLD }, breakLine: true, paraSpaceAfter: 14 } },
      { text: "previous_application — prior Home Credit applications, 1,413,553 records", options: { bullet: { code: "25AA", color: GOLD }, breakLine: true, paraSpaceAfter: 14 } },
      { text: "All joined on SK_ID_CURR, modeled and loaded into MySQL", options: { bullet: { code: "25AA", color: GOLD } } },
    ];
    slide.addText(dataPoints, {
      x: 7.2, y: 2.4, w: 5.2, h: 3.7,
      fontFace: FONT_BODY, fontSize: 13.5, color: CREAM,
      valign: "top", margin: 0,
    });

    footer(slide, 2);
  }

  // ---- Slides 3-7: the five questions -----------------------------------
  questionSlide(pres, {
    pageNum: 3,
    owner: "Aroa",
    status: "Done",
    question: "Which applicant profiles concentrate default risk?",
    statValue: "17.16%",
    statLabel: "default rate among Low-skill Laborers — the single highest segment we found, more than double the portfolio average.",
    chart: {
      headline: "Same signal from three different angles — job, housing, and education all point the same way, well above the 8.07% baseline.",
      seriesName: "Default rate",
      barDir: "bar",
      labels: ["Portfolio average", "Lower secondary edu.", "Drivers", "With parents", "Rented apartment", "Low-skill Laborers"],
      values: [8.07, 10.93, 11.33, 11.70, 12.32, 17.16],
      colors: ["8A6E6E", "6B0E1A", "6B0E1A", "6B0E1A", "6B0E1A", "6B0E1A"],
    },
    contextLine: "These combined profiles are the clearest candidates for extra guarantees or stricter lending terms.",
  });

  questionSlide(pres, {
    pageNum: 4,
    owner: "Paul",
    status: "Done",
    question: "How does prior credit history relate to default risk?",
    statValue: "15.79%",
    statLabel: "default rate for applicants with a troubled bureau history — the riskiest of three clear tiers.",
    findingLines: [
      "Applicants split cleanly into a 3-tier risk gradient by bureau credit history.",
      "Clean history: 7.62% default. No history on file: 10.13%. Troubled history: 15.79%.",
      "No history sits closer to \"troubled\" than \"clean\" — worth pricing risk in three tiers, not two.",
    ],
    contextLine: "Bureau history alone roughly doubles the observable risk range — a strong candidate for tiered pricing.",
  });

  questionSlide(pres, {
    pageNum: 5,
    owner: "Carla",
    status: "Done",
    question: "Is a returning client a better client than a new one?",
    statValue: "8.19%",
    statLabel: "default rate for returning clients overall, vs. 5.96% for brand-new applicants — the gap holds even for the cleanest returning-client histories.",
    findingLines: [
      "Counter-intuitive result: new clients default less (5.96%) than returning clients (8.19%).",
      "Mostly driven by refusal history: previously-refused clients hit 10.32%, vs. 7.13% (clean) and 6.94% (canceled).",
      "Ruled out application count and unused offers as the cause of the remaining gap — likely a selection effect the trimmed schema can't fully explain.",
    ],
    contextLine: "Loyalty and low risk aren't the same thing here — retention strategy may need its own risk lens.",
  });

  questionSlide(pres, {
    pageNum: 6,
    owner: "Aroa",
    status: "Done",
    question: "Were past rejections the right call?",
    statValue: "20.93%",
    statLabel: "default rate for applicants previously refused under reason code SCOFR — more than double the never-refused baseline.",
    chart: {
      headline: "Risk climbs with every extra refusal — this isn't a one-time flag, it's a dose-response pattern.",
      seriesName: "Default rate",
      barDir: "col",
      labels: ["Never Refused", "Refused Once", "Refused 2+ Times"],
      values: [6.98, 8.84, 11.61],
      colors: ["6B0E1A", "6B0E1A", "6B0E1A"],
    },
    contextLine: "The rejection criteria is picking up a real, persistent risk signal — not turning away good business by mistake.",
  });

  questionSlide(pres, {
    pageNum: 7,
    owner: "Carla",
    status: "Done",
    question: "Which products and channels concentrate risk?",
    statValue: "11.28%",
    statLabel: "default rate through the AP+ (Cash loan) channel — the single riskiest channel, and part of the riskiest product/channel combo.",
    findingLines: [
      "Cards is the riskiest product (9.55%); AP+ (Cash loan) is the riskiest channel (11.28%).",
      "Riskiest combination: XNA product through the AP+ channel, at 14.45%.",
      "Default rate climbs steadily with yield group, from 6.38% (low) to 9.01% (high) — pricing already tracks risk here.",
    ],
    contextLine: "Products and channels to restrict or re-price are now identified — pricing on yield group is already working as intended.",
  });

  // ---- Slide 8: Closing part 1 -- Where to tighten (3-card row) ---------
  {
    const slide = pres.addSlide();
    slide.background = { color: BURGUNDY_DARK };

    slide.addShape("ellipse", {
      x: -2, y: -2.5, w: 6, h: 6,
      fill: { color: BURGUNDY, transparency: 45 },
      line: { type: "none" },
    });

    slide.addText("Where to Tighten", {
      x: 0.7, y: 0.6, w: 11, h: 0.75,
      fontFace: FONT_HEAD, fontSize: 32, bold: true, color: CREAM,
      margin: 0,
    });
    slide.addText("Three places the current process is right, or needs sharper tiers", {
      x: 0.7, y: 1.3, w: 11, h: 0.4,
      fontFace: FONT_BODY, italic: true, fontSize: 14, color: "E3C9C3",
      margin: 0,
    });

    const tightenCards = [
      {
        stat: "3 Signals",
        title: "Overlapping Risk Profile",
        body: "Low-skill occupation, unstable housing, and low education concentrate risk together. Screen for the combination, not one factor at a time.",
      },
      {
        stat: "20.93%",
        title: "SCOFR = Real Red Flag",
        body: "Keep current rejection criteria. Refusals under this reason code predict real, persistent risk -- even after a later approval.",
      },
      {
        stat: "2x Range",
        title: "Bureau History, 3 Tiers",
        body: "Clean, no-history, and troubled span 7.62% to 15.79% default. No history behaves like troubled, not clean -- price it that way.",
      },
    ];
    const cardW = 3.9, gap = 0.3, startX = 0.7, cardY = 2.15, cardH = 4.15;
    tightenCards.forEach((c, i) => {
      const x = startX + i * (cardW + gap);
      slide.addShape("roundRect", {
        x, y: cardY, w: cardW, h: cardH,
        rectRadius: 0.12,
        fill: { color: BURGUNDY },
        line: { type: "none" },
        shadow: freshShadow(),
      });
      slide.addText(c.stat, {
        x: x + 0.3, y: cardY + 0.35, w: cardW - 0.6, h: 0.7,
        fontFace: FONT_HEAD, fontSize: 30, bold: true, color: GOLD,
        margin: 0,
      });
      slide.addText(c.title, {
        x: x + 0.3, y: cardY + 1.15, w: cardW - 0.6, h: 0.7,
        fontFace: FONT_BODY, fontSize: 15, bold: true, color: CREAM,
        margin: 0,
      });
      slide.addText(c.body, {
        x: x + 0.3, y: cardY + 1.85, w: cardW - 0.6, h: 2.1,
        fontFace: FONT_BODY, fontSize: 12.5, color: "E3C9C3",
        valign: "top", margin: 0, lineSpacingMultiple: 1.2,
      });
    });

    footer(slide, 8);
  }

  // ---- Slide 9: Closing part 2 -- Two things to rethink (2-card row) -----
  {
    const slide = pres.addSlide();
    slide.background = { color: BURGUNDY_DARK };

    slide.addShape("ellipse", {
      x: 9.5, y: 4, w: 6, h: 6,
      fill: { color: BURGUNDY, transparency: 45 },
      line: { type: "none" },
    });

    slide.addText("Two Things to Rethink", {
      x: 0.7, y: 0.6, w: 11, h: 0.75,
      fontFace: FONT_HEAD, fontSize: 32, bold: true, color: CREAM,
      margin: 0,
    });
    slide.addText("Where the data pushes back on current assumptions", {
      x: 0.7, y: 1.3, w: 11, h: 0.4,
      fontFace: FONT_BODY, italic: true, fontSize: 14, color: "E3C9C3",
      margin: 0,
    });

    const rethinkCards = [
      {
        stat: "8.19% vs 5.96%",
        title: "Loyalty ≠ Lower Risk",
        body: "Returning clients default more than brand-new ones. Retention pricing needs its own risk model, not a blanket loyalty discount.",
      },
      {
        stat: "14.45%",
        title: "One Combination Stands Out",
        body: "The XNA product sold through the AP+ (Cash loan) channel is disproportionately risky -- worth restricting or re-pricing on its own.",
      },
    ];
    const cardW2 = 5.9, gap2 = 0.5, startX2 = 0.7, cardY2 = 2.15, cardH2 = 4.15;
    rethinkCards.forEach((c, i) => {
      const x = startX2 + i * (cardW2 + gap2);
      slide.addShape("roundRect", {
        x, y: cardY2, w: cardW2, h: cardH2,
        rectRadius: 0.12,
        fill: { color: BURGUNDY },
        line: { type: "none" },
        shadow: freshShadow(),
      });
      slide.addText(c.stat, {
        x: x + 0.4, y: cardY2 + 0.45, w: cardW2 - 0.8, h: 1.1,
        fontFace: FONT_HEAD, fontSize: 44, bold: true, color: GOLD,
        margin: 0,
      });
      slide.addText(c.title, {
        x: x + 0.4, y: cardY2 + 1.6, w: cardW2 - 0.8, h: 0.6,
        fontFace: FONT_BODY, fontSize: 17, bold: true, color: CREAM,
        margin: 0,
      });
      slide.addText(c.body, {
        x: x + 0.4, y: cardY2 + 2.25, w: cardW2 - 0.8, h: 1.8,
        fontFace: FONT_BODY, fontSize: 13.5, color: "E3C9C3",
        valign: "top", margin: 0, lineSpacingMultiple: 1.25,
      });
    });

    footer(slide, 9);
  }

  const outPath = "/private/tmp/claude-501/-Users-aroaxinping-aroaxinping-com/37d5ddfb-7ba0-4794-86a1-1aa9496adfcf/scratchpad/slides/credit_crunchers_skeleton.pptx";
  await pres.writeFile({ fileName: outPath });
  console.log("wrote", outPath);
}

main().catch((e) => { console.error(e); process.exit(1); });
