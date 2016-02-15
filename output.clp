(deffunction fitnessMsg(?num)
	(if (< ?num 13107) then
        (return "Pain is just weakness leaving your body!")
        else (if (< ?num 26214) then
            (return "Keep calm and Keep working out!")
            else (if (< ?num 39321) then
                (return "You are only one workout away from a good mood!")
                else (if (< ?num 52428) then
                    (return "Motivation will always beat mere talent!")
                    else
                    (return "Energy and Persistance conquer all things")))))
)

(defrule dispOutputWelcome
	?p <- (person{bmi != nil}(personName ?name))
    ?p1 <- (fatLevel {personName == p.personName})
   	=>
    (printout t crlf crlf "**************************************************WELCOME TO FITNESS STAR*******************************************************************" crlf)
	(printout t crlf crlf "*********************************************YOUR PERSONAL FITNESS EXPERT SYSTEM************************************************************" crlf)
    (printout t "Hello there. " ?name "!" crlf crlf)
    (printout t "Below is the information you entered." crlf)
    (printout t "Your gender is " ?p.sex crlf)
    (printout t "Your age is " ?p.age crlf)
    (printout t "You regular life style is a " ?p.activityType " lifestyle" crlf) 
    (printout t "Based on your hieght and weight your Body Mass Index is " ?p.bmi crlf)
    (printout t "Based on your BMI you have been categorized as " ?p1.FatLevelDesc crlf)
	(if (floatp ?p.bodyFatPercentage) then
		(printout t "Your body fat percentage is " ?p.bodyFatPercentage crlf crlf))    
)  
(run)

(defrule disImmediateDiagnosisDiab
	?p <- (diabeticCondition (personName ?name))
    =>
    (printout t "Based on your sugar level I diagnosed " ?p.desc crlf)
    (printout t "I recommend you to consult your physician in order for proper medication if required." crlf crlf)    
)
(run)

(defrule disImmediateDiagnosisHeartCondn
	?p <- (coronaryHeartCondn (personName ?name))
    =>
    (printout t "Based on the systolic and diastolic ratings you have provided you currently are categorized as " ?p.bloodPressureType crlf)
    (printout t "Based on your blood pressure levels, sleep patterns, obesity levels and stress levels I have diagnosed your coronary heart condition as " ?p.HDriskChancesAdj crlf )
    (printout t "I recommend you to consult your physician in order for proper medication if required." crlf crlf)    
)
(run)

(defrule fitnessOutput
	?p <- (weightPlan(personName ?name))
    =>
    (printout t crlf crlf  "*************************************************LETS TALK FITNESS************************************************************" crlf)    
    (if (or (< ?p.weightToBe 0) (> ?p.weightToBe 0) )then
		(printout t "To be fit according to BMI index you have to ")
	    (if (< ?p.weightToBe 0) then
	        (printout t "gain " (* ?p.weightToBe -1) " kgs." crlf)
	        else (if (> ?p.weightToBe 0) then
	            (printout t "lose " ?p.weightToBe " kgs." crlf)
	            else
	            (printout t " maintain your weight." crlf)))
	    (printout t "Your Basic Metabolic Rate (B.M.R.) is " ?p.BMR crlf)
	    (printout t "Your current daily calorie intake is " (integer ?p.NumCalToMaint) crlf)
	    (printout t "You should bring down your calorie intake to " (integer ?p.newIntakeCal) crlf)
	    (printout t "To assist proper metabolism in your body the recommended water intake each day (in ounces) is " (integer ?p.newIntakeWater) crlf crlf)
		(printout t crlf crlf "Hope to see you again." crlf "Thank you for using the Fitness Star! " crlf (fitnessMsg (random)) crlf)
     else
        (printout t "I think you are already fit!" crlf)
        (printout t crlf crlf "Hope to see you again." crlf "Thank you for using the Fitness Star! " crlf (fitnessMsg (random)) crlf)
        )
)

(run)


(defrule workoutOutput
	?p <- (workoutIntakePlan (personName ?name))
    =>
	(if (floatp ?p.calBurntPerDay) then
    (printout t "Your daily target should be a workout (running) for 90 minutes." crlf)
    (printout t "If you hit the target everyday I deduced you could burn " (integer ?p.calBurntPerDay) " calories every day." crlf) 
    (printout t "You should aim for a target heart rate of " ?p.targetHR "beats per minute" crlf)
    (printout t "If you are deligent in following what I recommend I am sure you will fit in " (integer ?p.targetDays) " days" crlf)   
    (printout t crlf crlf "Hope to see you again." crlf "Thank you for using the Fitness Star! " crlf (fitnessMsg (random)) crlf crlf)
	)
)
(run)

(reset)
(clear)
(exit)