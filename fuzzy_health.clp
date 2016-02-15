(import nrc.fuzzy.*)

(import nrc.fuzz.jess.*)

(load-package nrc.fuzzy.jess.FuzzyFunctions)

(deftemplate person
    (slot name)
    (slot weight (type INTEGER))
    (slot height (type INTEGER))
)

(deftemplate person_bmi
    "Auto-generated"
	(declare (ordered TRUE)))

(deftemplate person_sleep
    "Auto-generated"
    (declare (ordered TRUE)))

(deftemplate person_bp_sys
    "Auto-generated"
    (declare (ordered TRUE)))

(deftemplate person_bp_dias
    "Auto-generated"
    (declare (ordered TRUE)))

(deftemplate workout-p
    "Auto-generated"
    (declare (ordered TRUE)))

(deftemplate stress-level
    "Auto-generated"
    (declare (ordered TRUE)))

(deftemplate chd-risk
    "Auto-generated"
    (declare (ordered TRUE)))

(deftemplate sugar-level
    (slot level (type INTEGER))
)

(deftemplate diabeticCondition
    "Auto-generated"
    (declare (ordered TRUE)))

(deftemplate water-int
    "Auto-generated"
    (declare (ordered TRUE)))

(deftemplate cal-int
    "Auto-generated"
    (declare (ordered TRUE)))

(defglobal ?*bmiVar* = (new FuzzyVariable "bmi" 5 50))

(defglobal ?*sleepVar* = (new FuzzyVariable "sleep" 2 10 "Hours"))

(defglobal ?*bloodPressSVar* = (new FuzzyVariable "bloodPressDias" 0 190))

(defglobal ?*bloodPressDVar* = (new FuzzyVariable "bloodPressSys" 0 190))

(defglobal ?*workoutVar* = (new FuzzyVariable "workoutHours" 0 2))

(defglobal ?*stressVar* = (new FuzzyVariable "stressLevels" 0 10))

(defglobal ?*chdVar* = (new FuzzyVariable "chdRisk" 0 3))

(defglobal ?*diabVar* = (new FuzzyVariable "diabetesLevels" 30 200))

(defglobal ?*waterVar* = (new FuzzyVariable "WaterIntakeLevel" 0 500))

(defglobal ?*calVar* = (new FuzzyVariable "CalorieIntakeLevel" 500 2000))

(call nrc.fuzzy.FuzzyValue setMatchThreshold 0.2)

; Rule 1 - Initialize Global Variables
(defrule MAIN::init-FuzzyVariables
    (declare (salience 100))
    (initial-fact)
    =>
    (bind ?xunder (create$ 10 15 20))
    (bind ?yunder (create$ 1 1 0))
    (call ?*bmiVar* addTerm "underweight" ?xunder ?yunder 3)
    
    (bind ?xover (create$ 24 30))
    (bind ?yover (create$ 0 1))
    (call ?*bmiVar* addTerm "overweight" ?xover ?yover 2)
    
    (call ?*bmiVar* addTerm "normal" "not underweight and (not overweight)")
    
    (bind ?Sxlow (create$ 70 85 95))
    (bind ?Sylow (create$ 1 1 0))
    (call ?*bloodPressSVar* addTerm "low" ?Sxlow ?Sylow 3)
    
    (bind ?Dxlow (create$ 40 55 65))
    (bind ?Dylow (create$ 1 1 0))
    (call ?*bloodPressDVar* addTerm "low" ?Dxlow ?Dylow 3)
    
    (bind ?Sxhigh (create$ 115 130))
    (bind ?Syhigh (create$ 1 0))
    (call ?*bloodPressSVar* addTerm "hypertension" ?Sxhigh ?Syhigh 2)
    
    (bind ?Dxhigh (create$ 75 105))
    (bind ?Dyhigh (create$ 1 0))
    (call ?*bloodPressDVar* addTerm "hypertension" ?Dxhigh ?Dyhigh 2)
    
    (call ?*bloodPressSVar* addTerm "ideal" "not low and (not hypertension)")
    (call ?*bloodPressDVar* addTerm "ideal" "not low and (not hypertension)")
    
    (bind ?Pxsleep (create$ 0 4 6))
    (bind ?Pysleep (create$ 1 1 0))
    (call ?*sleepVar* addTerm "poor" ?Pxsleep ?Pysleep 3)
    
    (bind ?Nxsleep (create$ 6 8 10))
    (bind ?Nysleep (create$ 0 1 0))
    (call ?*sleepVar* addTerm "normal" ?Nxsleep ?Nysleep 3)
    
    (bind ?wLowx (create$ 0 1))
    (bind ?wLowy (create$ 1 0))
    (call ?*workoutVar* addTerm "light" ?wLowx ?wLowy 2)
    
    (bind ?wModx (create$ 0.5 1 2))
    (bind ?wMody (create$ 0 1 0))
    (call ?*workoutVar* addTerm "moderate" ?wModx ?wMody 3)
    
    (bind ?wIntx (create$ 0 1))
    (bind ?wInty (create$ 1 0))
    (call ?*workoutVar* addTerm "intense" ?wIntx ?wInty 2)
    
    (bind ?sx (create$ 0 5 10))
    (bind ?sy (create$ 1 1 0))
    (call ?*stressVar* addTerm "high" ?sx ?sy 3)
    
    (bind ?sx (create$ 0 5 10))
    (bind ?sy (create$ 0 0 1))
    (call ?*stressVar* addTerm "normal" ?sx ?sy 3)
    
    (bind ?cxm (create$ 0 1 2))
    (bind ?cym (create$ 0 1 0))
    (call ?*chdVar* addTerm "moderate" ?cxm ?cym 2)
    
    (bind ?cxh (create$ 2 3))
    (bind ?cyh (create$ 0 1))
    (call ?*chdVar* addTerm "high" ?cxm ?cym 2)
    
    (bind ?diabLowx (create$ 30 60 80))
    (bind ?diabLowy (create$ 1 1 0))
    (call ?*diabVar* addTerm "low" ?diabLowx ?diabLowy 3)
    
    (bind ?diabModx (create$ 93 99 105))
    (bind ?diabMody (create$ 0 1 0))
    (call ?*diabVar* addTerm "normal" ?diabModx ?diabMody 3)
    
    (bind ?diabHighx (create$ 105 125))
    (bind ?diabHighy (create$ 0 1))
    (call ?*diabVar* addTerm "high" ?diabHighx ?diabHighy 2)
    
)

; Rule 2 - Initialize the knowledge base
(defrule init
    (declare (salience 50))
=>
    ;; write assert statement here, try forming an interactive prompt
    (assert (person (name Batman)(height 1.6256)(weight 90))) ; 
    (assert (person_sleep (new nrc.fuzzy.FuzzyValue ?*sleepVar* "poor")))
    (assert (person_bp_sys (new nrc.fuzzy.FuzzyValue ?*bloodPressSVar* "hypertension")))
    (assert (person_bp_dias (new nrc.fuzzy.FuzzyValue ?*bloodPressDVar* "hypertension")))
    (assert (sugar-level (level 100)))    
)

; Rule 3 - Compute the BMI and fuzzify the outputs
(defrule fuzzify_bmi 
	?p <- (person (name ?name))
    =>
    (bind ?bm (/ ?p.weight (* ?p.height ?p.height))) 
    (printout t "Your BMI is calculated as " ?bm crlf)
    (assert (person_bmi (new nrc.fuzzy.FuzzyValue ?*bmiVar* (new SingletonFuzzySet ?bm))))
)

; Rule 4 - Recommend workout based on the BMI, moderate for normal people
(defrule mod_workout_required
	(person_bmi ?p&:(fuzzy-match ?p "normal"))
     =>
    (printout t "Based on your BMI you need a normal workout." crlf)
	(assert (workout-p (new nrc.fuzzy.FuzzyValue ?*workoutVar* "moderate")))  
)	

; Rule 5 - Recommend workout based on the BMI, intense for obese people
(defrule extrm_workout_required
	(person_bmi ?p&:(fuzzy-match ?p "overweight"))
     =>
    (printout t "Based on your BMI you need an extreme workout." crlf)
	(assert (workout-p (new nrc.fuzzy.FuzzyValue ?*workoutVar* "intense")))  
)

; Rule 6 - Compute the stress levels on the basis of poor sleep patterns and hyper tension
(defrule stress_lvls_high
    (person_sleep ?ps&:(fuzzy-match ?ps "poor"))
    (person_bp_sys ?pbp1&:(fuzzy-match ?pbp1 "more_or_less hypertension"))
    (person_bp_dias ?pbp2&:(fuzzy-match ?pbp2 "hypertension"))
    =>
	(assert (stress-level (new nrc.fuzzy.FuzzyValue ?*stressVar* "high")))
    (printout t "With your poor sleeping pattens and hypertension ")
    (printout t "you are diagnosed with very high stress." crlf) 
    (printout t "Your stress is to the degree of " (fuzzy-rule-similarity) crlf)
)

; Rule 7 - Compute the stress levels on the basis of poor sleep patterns and hyper tension
(defrule chd_risks_high
	(stress-level ?s&:(fuzzy-match ?s "high"))
	(person_bmi ?p&: (fuzzy-match ?p "extremely overweight"))
    =>
    (assert (chd-risk (new nrc.fuzzy.FuzzyValue ?*chdVar* "extremely high"))) 
    (printout t "With very high stress and obesity there are high chances of coronory heart diseases." crlf)   	    	
)

; Rule 8 - High risk implies higher chances of coronary heart diseases
(defrule chd_risks_mod
	(stress-level ?s&:(fuzzy-match ?s "more_or_less high"))
    (person_bmi ?p&: (fuzzy-match ?p "not overweight"))
    =>
    (assert (chd-risk (new nrc.fuzzy.FuzzyValue ?*chdVar* "moderate"))) 
    (printout t "With more or less high stress there are moderate chances of coronory heart diseases." crlf)  	    	
)


; Rule 9 - Compute the chances of diabetes based on sugar levels
(defrule diabetes_chck
	?s <- (sugar-level (level ?lvl))  
    =>
    (if (< ?s.level 70) then
        (assert (diabeticCondition (new nrc.fuzzy.FuzzyValue ?*diabVar* "low")))
        (printout t "You have low chances of diabetes." crlf)
     else (if (< ?s.level 99) then
            (assert (diabeticCondition (new nrc.fuzzy.FuzzyValue ?*diabVar* "normal")))
            (printout t "You have very little/no chances of diabetes." crlf)
            else (if (< ?s.level 125) then
                (assert (diabeticCondition (new nrc.fuzzy.FuzzyValue ?*diabVar* "high")))
                (printout t "You have high chances of diabetes." crlf)
                else 
                (assert (diabeticCondition (new nrc.fuzzy.FuzzyValue ?*diabVar* "extremely high")))
                (printout t "You have extremely high chances of diabetes." crlf))
            ))
)


; Rule 10 - In case of high risk of coronary heart disease and diabetes, call for immediate attention
(defrule disImmediateDiagnosisHeartCondn
    (diabeticCondition ?d&:(fuzzy-match ?d "high"))
	(chd-risk ?c&:(fuzzy-match ?c "extremely high"))
    =>
    (printout t "With such high chances of both diabetes and coronary heart conditions" crlf)
    (printout t "I recommend you to consult your physician in order for proper medication if required." crlf crlf)    
)


(reset)
(bind ?numrules (run))
(printout t "Rules fired is: " ?numrules crlf crlf)
(printout t crlf)

(printout t "Testing with: " crlf "   Rule Executor = " (get-default-fuzzy-rule-executor) crlf)
(printout t "   Antecedent Combine Operator = " (get-default-antecedent-combine-operator) crlf)
(printout t "   Global Contribution Operator = " (get-fuzzy-global-contribution-operator) crlf)
(printout t crlf)