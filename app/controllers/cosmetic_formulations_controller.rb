class CosmeticFormulationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_formulation, only: [:show]
  
  def index
    @formulations = current_user.cosmetic_formulations.order(created_at: :desc)
  end

  def new
    @formulation = current_user.cosmetic_formulations.build
  end

  def create
    @formulation = current_user.cosmetic_formulations.build(formulation_params)
    
    if @formulation.save
      # AI処方生成をバックグラウンドで実行（後で実装）
      generate_ai_formulation(@formulation)
      redirect_to @formulation, notice: 'AI処方を生成しています...'
    else
      render :new
    end
  end

  def show
  end
  
  private
  
  def set_formulation
    @formulation = current_user.cosmetic_formulations.find(params[:id])
  end
  
  def formulation_params
    params.require(:cosmetic_formulation).permit(:product_type, :skin_type, :concerns, :target_age)
  end
  
  def generate_ai_formulation(formulation)
    # 一時的にダミーデータで処方を生成
    prompt = build_ai_prompt(formulation)
    
    # 実際のAI APIを使用する場合はここでAPIを呼び出す
    # response = call_ai_api(prompt)
    
    # ダミーの処方データ
    dummy_formulation = generate_dummy_formulation(formulation)
    
    formulation.update(
      formulation: dummy_formulation,
      ai_response: "AI処方が正常に生成されました。"
    )
  end
  
  def build_ai_prompt(formulation)
    <<~PROMPT
      化粧品処方開発のエキスパートとして、以下の条件に基づいて化粧品処方を作成してください。

      製品タイプ: #{formulation.product_type_name}
      肌タイプ: #{formulation.skin_type_name}
      肌悩み: #{formulation.concerns}
      対象年齢: #{formulation.target_age_name}

      以下の情報を含む詳細な処方を作成してください：
      1. 成分リストとその配合率
      2. 各成分の効果・役割
      3. 製造工程の概要
      4. 使用上の注意点
      5. 期待できる効果

      安全性と効果性を考慮した、実際に製造可能な処方を提案してください。
    PROMPT
  end
  
  def generate_dummy_formulation(formulation)
    case formulation.product_type
    when 'toner'
      generate_toner_formulation(formulation)
    when 'moisturizer'
      generate_moisturizer_formulation(formulation)
    when 'serum'
      generate_serum_formulation(formulation)
    else
      generate_basic_formulation(formulation)
    end
  end
  
  def generate_toner_formulation(formulation)
    <<~FORMULATION
      【#{formulation.product_type_name} 処方】

      ■ 成分構成
      • 精製水: 85.0%
      • グリセリン: 5.0%
      • ヒアルロン酸Na: 0.5%
      • アロエベラ葉エキス: 2.0%
      • セラミドNP: 1.0%
      • パンテノール: 1.0%
      • フェノキシエタノール: 0.5%
      • 合計: 100.0%

      ■ 各成分の役割
      • 精製水: 基剤として全体の約85%を構成
      • グリセリン: 保湿成分として肌に潤いを与える
      • ヒアルロン酸Na: 高い保水力で肌の水分を保持
      • アロエベラ葉エキス: 鎮静・抗炎症効果
      • セラミドNP: 肌バリア機能をサポート
      • パンテノール: 肌荒れ防止、保湿効果
      • フェノキシエタノール: 防腐剤

      ■ 製造工程
      1. 精製水を70℃に加熱
      2. 水溶性成分を順次溶解
      3. 40℃まで冷却後、エキス類を添加
      4. pH調整（6.0-7.0）
      5. 最終確認後、容器充填

      ■ 期待効果
      • #{formulation.skin_type_name}に適した保湿効果
      • #{formulation.concerns}の改善サポート
      • 肌のキメを整える
      • #{formulation.target_age_name}の肌悩みに対応
    FORMULATION
  end
  
  def generate_moisturizer_formulation(formulation)
    <<~FORMULATION
      【#{formulation.product_type_name} 処方】

      ■ 成分構成
      • 精製水: 65.0%
      • スクワラン: 8.0%
      • セタノール: 3.0%
      • グリセリン: 5.0%
      • シアバター: 4.0%
      • セラミドAP: 2.0%
      • ナイアシンアミド: 2.0%
      • トコフェロール: 0.5%
      • 乳化剤: 2.0%
      • 防腐剤: 0.5%
      • その他添加物: 8.0%

      ■ 各成分の役割
      • 精製水: 基剤
      • スクワラン: エモリエント効果、肌の柔軟性向上
      • セタノール: 乳化安定剤、テクスチャー改善
      • グリセリン: 保湿成分
      • シアバター: 自然由来の保湿成分
      • セラミドAP: 肌バリア機能強化
      • ナイアシンアミド: 肌荒れ防止、美白効果
      • トコフェロール: 抗酸化成分

      ■ 製造工程
      1. 水相と油相を別々に75℃で加熱
      2. 乳化機で徐々に混合
      3. 45℃まで冷却しながら撹拌
      4. 有効成分を添加
      5. pH・粘度調整
      6. 品質確認後充填

      ■ 期待効果
      • 長時間持続する保湿効果
      • #{formulation.skin_type_name}の肌質改善
      • #{formulation.concerns}へのアプローチ
      • なめらかで弾力のある肌へ
    FORMULATION
  end
  
  def generate_serum_formulation(formulation)
    <<~FORMULATION
      【#{formulation.product_type_name} 処方】

      ■ 成分構成
      • 精製水: 75.0%
      • ビタミンC誘導体: 5.0%
      • ヒアルロン酸Na: 2.0%
      • ナイアシンアミド: 3.0%
      • アルブチン: 2.0%
      • ペプチド複合体: 1.0%
      • グリセリン: 5.0%
      • BG: 3.0%
      • キサンタンガム: 0.5%
      • フェノキシエタノール: 0.5%
      • その他: 3.0%

      ■ 各成分の役割
      • ビタミンC誘導体: 美白・抗酸化効果
      • ヒアルロン酸Na: 高保湿・プランピング効果
      • ナイアシンアミド: 毛穴・肌荒れケア
      • アルブチン: メラニン生成抑制
      • ペプチド複合体: エイジングケア成分
      • キサンタンガム: 増粘剤、使用感向上

      ■ 製造工程
      1. 精製水に水溶性成分を順次溶解
      2. 有効成分を低温で添加
      3. pH調整（5.5-6.5）
      4. 均質化処理
      5. 安定性確認
      6. 無菌充填

      ■ 期待効果
      • 集中的なスキンケア効果
      • 美白・透明感アップ
      • #{formulation.concerns}の改善
      • ハリ・弾力向上
      • #{formulation.target_age_name}向けの高機能ケア
    FORMULATION
  end
  
  def generate_basic_formulation(formulation)
    <<~FORMULATION
      【#{formulation.product_type_name} 処方】

      ■ 基本構成
      この製品タイプに適した基本処方を以下に示します。

      ■ 主要成分
      • 基剤成分: 製品の基本となる成分群
      • 有効成分: #{formulation.concerns}にアプローチする成分
      • 保湿成分: #{formulation.skin_type_name}に適した保湿剤
      • 安定化剤: 製品の品質を保つ成分

      ■ 特徴
      • #{formulation.target_age_name}の肌特性を考慮
      • #{formulation.skin_type_name}に最適化
      • #{formulation.concerns}の改善をサポート

      ■ 使用方法
      適量を手に取り、肌になじませてください。

      注意：この処方は参考例です。実際の製造には専門知識が必要です。
    FORMULATION
  end
end
