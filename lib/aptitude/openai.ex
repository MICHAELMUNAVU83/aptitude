defmodule Aptitude.OpenAI do
  @moduledoc """
  Client for OpenAI API calls — question generation and result analysis.
  """

  @api_url "https://api.openai.com/v1/chat/completions"

  defp api_key do
    Application.fetch_env!(:aptitude, :openai_api_key)
  end

  defp request(prompt) do
    Req.post(@api_url,
      json: %{
        model: "gpt-5",
        messages: [%{role: "user", content: prompt}],
        response_format: %{type: "json_object"},
        temperature: 0.2
      },
      headers: [
        {"Authorization", "Bearer #{api_key()}"}
      ],
      receive_timeout: 120_000,
      retry: :transient,
      max_retries: 3,
      retry_delay: fn attempt -> Integer.pow(2, attempt) * 500 end
    )
    |> case do
      {:ok, %{status: status, body: body}} ->
        {:ok, %{status: status, body: body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # ============================================================
  # QUESTION TYPE TEMPLATES
  # These are the actual formats used in real aptitude tests
  # (SHL, Wonderlic, Kenexa, etc). The AI is shown concrete
  # examples of EACH TYPE so it mimics the real format exactly.
  # ============================================================

  @question_type_templates """
  Below are the EXACT question formats you must use. Mix these types throughout the test.
  Study each format carefully and replicate the style precisely.

  ---

  TYPE 1 — NUMBER SERIES
  Find the missing number in the sequence.
  Example:
    Q: 2, 6, 18, 54, ___
    A options: A. 108  B. 162  C. 72  D. 216
    Answer: B (multiply by 3 each time)

  Example 2:
    Q: 144, 121, 100, 81, ___
    A options: A. 64  B. 60  C. 72  D. 56
    Answer: A (perfect squares: 12², 11², 10², 9², 8²)

  ---

  TYPE 2 — NUMERICAL WORD PROBLEM (with Kenyan context)
  A real-world maths problem requiring 1-3 calculation steps.
  Example:
    Q: A salesperson at Nairobi's Westgate earns a base salary of KES 35,000 per month plus a 4% commission on all sales. If she sells goods worth KES 250,000 in a month, what is her total monthly earnings?
    A options: A. KES 43,000  B. KES 45,000  C. KES 47,000  D. KES 49,000
    Answer: B (35,000 + 0.04 × 250,000 = 35,000 + 10,000 = 45,000)

  Example 2:
    Q: A shopkeeper in Mombasa buys a dress for KES 1,200 and sells it for KES 1,560. What is the profit percentage?
    A options: A. 25%  B. 30%  C. 32%  D. 36%
    Answer: B (Profit = 360, 360/1200 × 100 = 30%)

  ---

  TYPE 3 — RATIO, PERCENTAGE & PROPORTION
  Example:
    Q: In a company with 240 employees, the ratio of men to women is 5:3. How many women work there?
    A options: A. 80  B. 90  C. 96  D. 100
    Answer: B (3/8 × 240 = 90)

  Example 2:
    Q: A mobile plan costs KES 800 per month. The provider increases the price by 15%, then offers a 10% loyalty discount on the new price. What is the final monthly cost?
    A options: A. KES 828  B. KES 836  C. KES 840  D. KES 855
    Answer: A (800 × 1.15 = 920, then 920 × 0.90 = 828)

  ---

  TYPE 4 — TIME, SPEED & WORK
  Example:
    Q: Amina can complete a report in 6 hours. Brian can complete the same report in 4 hours. If they work together, how long will it take them to complete one report?
    A options: A. 2 hours  B. 2 hours 24 minutes  C. 2 hours 40 minutes  D. 3 hours
    Answer: B (Combined rate = 1/6 + 1/4 = 5/12, time = 12/5 = 2.4 hours = 2h 24m)

  Example 2:
    Q: A matatu travelling from Nairobi to Nakuru (160 km) leaves at 7:00 AM at 80 km/h. A second matatu leaves at 8:00 AM at 100 km/h on the same route. At what time does the second matatu overtake the first?
    A options: A. 10:00 AM  B. 10:20 AM  C. 10:40 AM  D. 11:00 AM
    Answer: A (First matatu has 80km head start. Relative speed = 20 km/h. Time to close gap = 80/20 = 4 hours after 2nd departs = 12:00 PM... recalculate for the numbers you choose)

  ---

  TYPE 5 — VERBAL REASONING: TRUE / FALSE / CANNOT TELL
  Candidate reads a short passage, then judges a statement.
  Example:
    Passage: "Safaricom reported that M-Pesa processed over 10 trillion shillings in transactions in 2023, making it one of the most-used mobile money platforms in the world. The service is available in seven African countries."

    Statement: M-Pesa is available in more than five African countries.
    A options: A. True  B. False  C. Cannot Tell
    Answer: A (The passage states seven countries, which is more than five.)

    Statement: M-Pesa is the largest mobile money platform in the world.
    A options: A. True  B. False  C. Cannot Tell
    Answer: C (The passage says "one of the most-used" — we cannot confirm it is the largest.)

  ---

  TYPE 6 — VERBAL REASONING: WORD ANALOGY
  Example:
    Q: Pen is to Writer as Scalpel is to ___
    A options: A. Hospital  B. Surgeon  C. Nurse  D. Medicine
    Answer: B (A pen is the primary tool of a writer; a scalpel is the primary tool of a surgeon)

  Example 2:
    Q: Nairobi is to Kenya as Kampala is to ___
    A options: A. Tanzania  B. Rwanda  C. Uganda  D. Ethiopia
    Answer: C

  ---

  TYPE 7 — VERBAL REASONING: ODD ONE OUT
  Example:
    Q: Which word does NOT belong in the group?
    Equity Bank | KCB | Stanbic | NSE | Cooperative Bank
    A options: A. Equity Bank  B. KCB  C. NSE  D. Stanbic
    Answer: C (NSE is a stock exchange; the others are commercial banks)

  ---

  TYPE 8 — LOGICAL REASONING: STATEMENT & CONCLUSION
  Example:
    Q: Statement: "All managers at the company attended the leadership workshop. John did not attend the leadership workshop."
    Conclusion: John is not a manager at the company.
    A options: A. Conclusion definitely follows  B. Conclusion definitely does not follow  C. Conclusion may or may not follow  D. Cannot be determined
    Answer: A (Valid deductive logic — if all managers attended and John did not, John cannot be a manager)

  ---

  TYPE 9 — LOGICAL REASONING: CODING / PATTERN
  Example:
    Q: If in a certain code, KENYA is written as MGPAC, how is NAIROBI written in that code?
    A options: A. PCKTQDK  B. PCKQTDK  C. PCKQSDK  D. PCKTQDK
    Answer: A (each letter shifted +2 positions in the alphabet)

  ---

  TYPE 10 — SITUATIONAL JUDGEMENT
  Example:
    Q: You are a junior accountant and you discover that a colleague has been approving petty cash claims that appear to be fraudulent — small amounts, but consistent over several months. Your colleague is well-liked and senior to you. What is the MOST appropriate first action?
    A options:
      A. Ignore it — the amounts are small and it is not your problem
      B. Confront the colleague directly and ask them to explain
      C. Report your concern through the company's internal whistleblower or reporting channel
      D. Tell other colleagues to see if anyone else has noticed
    Answer: C (Proper governance procedures exist for exactly this situation; direct confrontation or gossip could escalate the issue unprofessionally)

  ---

  TYPE 11 — ABSTRACT / SPATIAL REASONING
  These questions test non-verbal reasoning using shapes, patterns, rotations, and spatial transformations.
  Describe every shape precisely in words so candidates can visualise the pattern.
  Example:
    Q: Look at the following sequence of shapes: Circle, Square, Triangle, Circle, Square, ___. What comes next?
    A options: A. Circle  B. Square  C. Triangle  D. Pentagon
    Answer: C (The pattern repeats: Circle → Square → Triangle)

  Example 2:
    Q: A square is rotated 45° to form a diamond. The diamond is then cut in half along its vertical axis. What shape is each resulting piece?
    A options: A. Two rectangles  B. Two right-angled triangles  C. Two equilateral triangles  D. Two isosceles triangles
    Answer: D (Cutting a diamond vertically produces two identical isosceles triangles)

  Example 3:
    Q: In a pattern matrix, each row contains a circle, a triangle, and a square. Each shape is filled with one of three patterns: solid, striped, or empty. In Row 1: solid circle, striped triangle, empty square. In Row 2: striped square, empty circle, solid triangle. In Row 3: empty triangle, solid square, ___. What is the missing shape and pattern?
    A options: A. Striped circle  B. Solid circle  C. Empty circle  D. Striped square
    Answer: A (Each row has all 3 shapes and all 3 fills exactly once; Row 3 is missing a circle and the striped fill)

  Example 4:
    Q: A piece of paper is folded in half, then in half again. A single hole is punched through all layers. When the paper is unfolded, how many holes are visible?
    A options: A. 1  B. 2  C. 4  D. 8
    Answer: C (Two folds create 4 layers, so 1 punch = 4 holes when unfolded)

  Example 5:
    Q: Which shape does NOT fit the pattern? All shapes are: a small black circle inside a large white circle, a small white square inside a large black square, a small black triangle inside a large white triangle, a small black star inside a large black star.
    A options: A. Circle pair  B. Square pair  C. Triangle pair  D. Star pair
    Answer: D (In all other pairs, the inner and outer shapes have opposite fills — black/white or white/black — but the star pair has the same fill: both black)
  """

  @sector_knowledge %{
    "General Knowledge" =>
      "Kenyan history & politics, East African geography, science fundamentals, current affairs in Kenya and Africa, world capitals, Kenyan culture and national symbols, abstract reasoning (shape sequences, spatial transformations, pattern matrices, paper folding, figure classification)",
    "Marketing" =>
      "4Ps, brand positioning, digital marketing (SEO/social/email), consumer behaviour, market research, Kenyan advertising landscape, ROI calculations, campaign planning",
    "Software Engineering" =>
      "data structures, algorithms, OOP, SQL, REST APIs, Git, SDLC/Agile, system design, debugging logic, cybersecurity basics, code output reasoning",
    "Finance & Accounting" =>
      "financial statements, double-entry bookkeeping, KRA tax (PAYE/VAT), NSE, banking (CBK/M-Pesa/CRB), financial ratios, compound interest, NPV, budgeting",
    "Human Resources" =>
      "Kenya Employment Act 2007, recruitment, performance management, statutory deductions (NHIF/NSSF/housing levy), employee relations, HR metrics, motivation theories",
    "Sales" =>
      "sales process, objection handling, CRM, pipeline metrics (CAC/LTV/conversion), negotiation, Kenyan B2B/B2C context, commission calculations",
    "Supply Chain & Logistics" =>
      "procurement, EOQ, JIT, SGR/Mombasa Port, Incoterms, KRA import duties, demand forecasting, cold chain, total landed cost calculations"
  }

  @difficulty_mix %{
    "easy" => %{
      types: "Focus on TYPE 1, TYPE 2, TYPE 3, TYPE 5, TYPE 6, TYPE 7, TYPE 11",
      note:
        "Use simple numbers (no decimals). Passages should be short (2-3 sentences). Analogies should be obvious. Scoring: a prepared candidate should get 75%+."
    },
    "medium" => %{
      types: "Use ALL types (TYPE 1 through TYPE 11). Spread evenly.",
      note:
        "Calculations require 2 steps. Passages are 4-5 sentences. Include at least 2 situational judgement questions. Some distractors should look very plausible."
    },
    "hard" => %{
      types:
        "Heavy on TYPE 2, TYPE 4, TYPE 5, TYPE 8, TYPE 10, TYPE 11. Include at least 3 TYPE 10 situational questions and at least 2 TYPE 11 abstract reasoning questions.",
      note:
        "Multi-step calculations. Longer passages (6-8 sentences). Statements in Type 5 should require careful reading — 'Cannot Tell' answers should be genuinely non-obvious. A strong expert candidate should score ~65%. All 4 options must be plausible — no obviously wrong answers."
    }
  }

  @sector_type_overrides %{
    "Software Engineering" => %{
      types:
        "Focus heavily on TYPE 8 (Statement & Conclusion / logical deduction), TYPE 9 (Coding/Pattern), TYPE 11 (Abstract/Spatial Reasoning). Include some TYPE 1 (Number Series). Do NOT generate KES salary word problems — instead use algorithm complexity, loop output, binary/hex conversions, or code tracing as the numerical context.",
      note:
        "Questions should test logical reasoning, code output prediction, algorithm analysis, and pattern recognition. E.g. 'What does this loop output?', 'Which sorting algorithm is O(n log n)?', 'What is the next value in this binary sequence?'. Keep it technical but reasoning-focused."
    }
  }

  def generate_questions(sector, difficulty, count) do
    knowledge_area = Map.get(@sector_knowledge, sector, sector)
    diff = Map.get(@sector_type_overrides, sector) || Map.get(@difficulty_mix, difficulty, @difficulty_mix["medium"])

    prompt = """
    You are a senior psychometric test designer. You create pre-employment aptitude tests used by top Kenyan employers like Safaricom, KCB, Equity Bank, and Unilever Kenya. Your tests follow the same format as SHL, Kenexa, and Wonderlic assessments.

    === YOUR TASK ===
    Generate #{count} multiple choice aptitude questions for a #{difficulty} difficulty test.
    Topic / Sector: #{sector}
    Subject knowledge to draw from: #{knowledge_area}

    === QUESTION FORMAT LIBRARY ===
    You MUST use the following question formats. Study them carefully — your questions must look exactly like these examples in terms of style, structure, and rigour:

    #{@question_type_templates}

    === QUESTION MIX FOR THIS TEST ===
    #{diff.types}
    #{diff.note}

    === RULES ===
    1. Every question must have EXACTLY ONE correct answer. Test this yourself before writing the options.
    2. All 4 options must be plausible — never include an obviously silly distractor.
    3. For numerical questions: work out the answer step-by-step FIRST, verify it, THEN write the options. The correct answer must be mathematically exact. Never place a wrong value as the correct_answer.
    4. Use Kenyan context naturally: KES for currency, Kenyan company names (Safaricom, KCB, Equity, Twiga Foods, Jumia Kenya, Kenya Power, KPLC, Nation Media, etc.), Kenyan cities and geography, Kenyan laws and institutions.
    5. Do NOT repeat the same question style back-to-back. Vary the type with every question.
    6. Do NOT generate all knowledge/definition questions. This is an APTITUDE test — it tests REASONING, not memorisation.
    7. Each question must test a different concept. No duplicates.

    === OUTPUT FORMAT ===
    Return ONLY valid JSON. No markdown. No code fences. No explanation. Begin with { and end with }.

    {
      "questions": [
        {
          "type": "Number Series | Word Problem | Ratio/Percentage | Time/Speed/Work | Verbal True/False | Word Analogy | Odd One Out | Statement & Conclusion | Coding Pattern | Situational Judgement | Abstract/Spatial Reasoning",
          "question": "Full question text. For verbal reasoning, include the full passage first, then the statement or question.",
          "options": ["A. ...", "B. ...", "C. ...", "D. ..."],
          "correct_answer": "A",
          "explanation": "Step-by-step working or reasoning. For numerics, show the full calculation. For verbal, explain why the other options are wrong.",
          "sub_topic": "e.g. Profit & Loss, Verbal Passage Inference, Sales Objection Handling"
        }
      ]
    }
    """

    case request(prompt) do
      {:ok, %{status: 200, body: body}} ->
        content = get_in(body, ["choices", Access.at(0), "message", "content"])
        clean = Regex.replace(~r/```(?:json)?\n?|\n?```/, content, "")

        case Jason.decode(clean) do
          {:ok, parsed} ->
            questions = parsed["questions"] || []
            # Basic sanity check: log a warning if any question has identical options
            validated =
              Enum.filter(questions, fn q ->
                unique_options = q["options"] |> Enum.uniq() |> length()
                unique_options == 4
              end)

            {:ok, validated}

          {:error, _} ->
            {:error, "Failed to parse AI response as JSON. Raw: #{String.slice(clean, 0, 300)}"}
        end

      {:ok, %{status: status, body: body}} ->
        {:error, "OpenAI error #{status}: #{inspect(body)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def analyse_results(sector, difficulty, questions, answers_map) do
    # ── 1. Build enriched Q&A list ──────────────────────────────────────────
    qa_list =
      Enum.map(questions, fn q ->
        candidate_answer = Map.get(answers_map, q.id, "No answer")
        is_correct = candidate_answer != "No answer" && candidate_answer == q.correct_answer

        %{
          question_type: Map.get(q, :type, "General"),
          sub_topic: Map.get(q, :sub_topic, "General"),
          question: q.body,
          options: q.options,
          correct_answer: q.correct_answer,
          candidate_answer: candidate_answer,
          is_correct: is_correct,
          was_skipped: candidate_answer == "No answer"
        }
      end)

    # ── 2. Pre-compute all stats in Elixir (don't trust AI to count) ────────
    total = length(qa_list)
    correct_count = Enum.count(qa_list, & &1.is_correct)
    wrong_count = Enum.count(qa_list, &(!&1.is_correct && !&1.was_skipped))
    skipped_count = Enum.count(qa_list, & &1.was_skipped)
    score_pct = if total > 0, do: Float.round(correct_count / total * 100, 1), else: 0.0

    # ── 3. Sub-topic breakdown ───────────────────────────────────────────────
    sub_topic_breakdown =
      qa_list
      |> Enum.group_by(& &1.sub_topic)
      |> Enum.map(fn {topic, qs} ->
        topic_correct = Enum.count(qs, & &1.is_correct)
        topic_skipped = Enum.count(qs, & &1.was_skipped)
        topic_total = length(qs)
        topic_pct = Float.round(topic_correct / topic_total * 100, 1)

        %{
          sub_topic: topic,
          correct: topic_correct,
          wrong: topic_total - topic_correct - topic_skipped,
          skipped: topic_skipped,
          total: topic_total,
          score_pct: topic_pct,
          performance:
            cond do
              topic_pct >= 75 -> "Strong"
              topic_pct >= 50 -> "Moderate"
              true -> "Weak"
            end
        }
      end)
      |> Enum.sort_by(& &1.score_pct, :desc)

    # ── 4. Question-type breakdown ───────────────────────────────────────────
    question_type_breakdown =
      qa_list
      |> Enum.group_by(& &1.question_type)
      |> Enum.map(fn {type, qs} ->
        type_correct = Enum.count(qs, & &1.is_correct)
        type_total = length(qs)

        %{
          question_type: type,
          correct: type_correct,
          total: type_total,
          score_pct: Float.round(type_correct / type_total * 100, 1)
        }
      end)
      |> Enum.sort_by(& &1.score_pct, :desc)

    # ── 5. Flag specific wrong answers for the interviewer ──────────────────
    find_option_text = fn options, letter ->
      Enum.find(options, fn opt -> String.starts_with?(opt, letter <> ".") end) || letter
    end

    wrong_answers_detail =
      qa_list
      |> Enum.reject(& &1.is_correct)
      |> Enum.map(fn q ->
        %{
          sub_topic: q.sub_topic,
          question: q.question,
          correct_answer: q.correct_answer,
          correct_answer_text: find_option_text.(q.options, q.correct_answer),
          candidate_answer: q.candidate_answer,
          candidate_answer_text:
            if(q.was_skipped, do: nil, else: find_option_text.(q.options, q.candidate_answer)),
          was_skipped: q.was_skipped
        }
      end)

    # ── 6. Compute hiring grade ──────────────────────────────────────────────
    grade =
      cond do
        score_pct >= 80 -> "Distinction"
        score_pct >= 65 -> "Pass"
        score_pct >= 50 -> "Borderline"
        true -> "Below Standard"
      end

    hiring_recommendation =
      cond do
        score_pct >= 80 ->
          "Strong Pass — candidate is ready for interview immediately"

        score_pct >= 65 ->
          "Pass — recommend proceeding to interview with minor probing on weak areas"

        score_pct >= 50 ->
          "Borderline — proceed with caution; use interview to probe weak areas deeply"

        true ->
          "Not Recommended — significant knowledge gaps identified"
      end

    # ── 7. Build the AI prompt ───────────────────────────────────────────────
    prompt = """
    You are a senior talent assessor writing a structured evaluation report for a Kenyan hiring manager or HR panel.
    This report will be read by the interviewer BEFORE the candidate enters the room.
    Your job is to give the interviewer everything they need to probe the candidate intelligently.

    ════════════════════════════════════════
    TEST SUMMARY (pre-computed — do NOT recalculate)
    ════════════════════════════════════════
    Sector:             #{sector}
    Difficulty:         #{difficulty}
    Total Questions:    #{total}
    Correct:            #{correct_count}
    Wrong:              #{wrong_count}
    Skipped/Unanswered: #{skipped_count}
    Score:              #{score_pct}%
    Grade:              #{grade}

    ════════════════════════════════════════
    SUB-TOPIC PERFORMANCE
    ════════════════════════════════════════
    #{Jason.encode!(sub_topic_breakdown, pretty: true)}

    ════════════════════════════════════════
    QUESTION-TYPE PERFORMANCE
    ════════════════════════════════════════
    #{Jason.encode!(question_type_breakdown, pretty: true)}

    ════════════════════════════════════════
    QUESTIONS THE CANDIDATE GOT WRONG
    ════════════════════════════════════════
    #{Jason.encode!(wrong_answers_detail, pretty: true)}

    ════════════════════════════════════════
    YOUR TASK — produce the following sections:
    ════════════════════════════════════════

    1. STRENGTHS (2–4 bullet points)
       Be specific. Name the exact sub-topics where the candidate performed well.
       Reference the score percentages from the breakdown above.

    2. WEAKNESSES (2–4 bullet points)
       Name the exact sub-topics where they failed or skipped.
       If they skipped many questions, flag whether it looks like time management or knowledge gaps
       (hint: if they got easy types wrong but skipped harder ones → knowledge gap;
        if they got the first questions right then skipped the rest → time management).

    3. INTERVIEWER PROBE QUESTIONS (3–5 questions)
       Write specific questions the interviewer should ask this candidate based on their WRONG answers.
       These must be targeted to the actual sub-topics they struggled with.
       Example format: "Candidate answered [X] instead of [Y] on a profit & loss question —
       ask them to walk you through how they would calculate a 20% markup on a KES 5,000 item."
       Make these practical and relevant to the Kenyan job market.

    4. RED FLAGS (if any)
       Flag anything concerning: e.g. skipped an entire topic area, scored 0% on a core sub-topic
       for the role, pattern of guessing (picking A for everything), very slow progression suggesting
       poor time management, or score much lower than expected for stated experience level.
       If there are no red flags, write "None identified."

    5. OVERALL RECOMMENDATION
       One paragraph (4–5 sentences). Write as if briefing the hiring panel five minutes before the
       interview. Be direct and honest. Reference the Kenyan job context where relevant
       (e.g. "for a role at a Kenyan FMCG company, this score on the marketing ROI questions is concerning").
       End with a clear verdict: proceed / proceed with caution / do not proceed.

    ════════════════════════════════════════
    OUTPUT FORMAT
    ════════════════════════════════════════
    Return ONLY valid JSON. No markdown, no code fences, no preamble.
    Start with { and end with }.

    {
      "score_percentage": #{score_pct},
      "correct_count": #{correct_count},
      "wrong_count": #{wrong_count},
      "skipped_count": #{skipped_count},
      "total_questions": #{total},
      "grade": "#{grade}",
      "hiring_recommendation": "#{hiring_recommendation}",
      "sub_topic_breakdown": <copy from pre-computed data>,
      "question_type_breakdown": <copy from pre-computed data>,
      "strengths": ["...", "..."],
      "weaknesses": ["...", "..."],
      "interviewer_probe_questions": [
        {
          "area": "Sub-topic name",
          "context": "What the candidate got wrong",
          "probe_question": "The exact question the interviewer should ask"
        }
      ],
      "red_flags": ["..." ],
      "summary": "Full recommendation paragraph here."
    }
    """

    case request(prompt) do
      {:ok, %{status: 200, body: body}} ->
        content = get_in(body, ["choices", Access.at(0), "message", "content"])
        clean = Regex.replace(~r/```(?:json)?\n?|\n?```/, content, "")

        case Jason.decode(clean) do
          {:ok, parsed} ->
            # Merge in the pre-computed breakdowns so they're always accurate
            # even if the AI tried to rewrite them
            enriched =
              parsed
              |> Map.put("sub_topic_breakdown", sub_topic_breakdown)
              |> Map.put("question_type_breakdown", question_type_breakdown)
              |> Map.put("wrong_answers_detail", wrong_answers_detail)
              |> Map.put("score_percentage", score_pct)
              |> Map.put("correct_count", correct_count)
              |> Map.put("wrong_count", wrong_count)
              |> Map.put("skipped_count", skipped_count)
              |> Map.put("grade", grade)

            {:ok, enriched}

          {:error, _} ->
            {:error, "Failed to parse AI analysis. Raw: #{String.slice(clean, 0, 300)}"}
        end

      {:ok, %{status: status, body: body}} ->
        {:error, "OpenAI error #{status}: #{inspect(body)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
