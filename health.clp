/*
	Description: (outdated) This clp file contains the type definition for the person in consideration.
	Author: Sreejith Menon
	UIN: 673420442
	Date of Creation: 01/22/2016
*/

(deftemplate person
    (slot personName)
    (slot age (type INTEGER))
    ; either M or F
    (slot sex (allowed-values M F))
    ; height in m
    (slot height (type INTEGER))
    ; weight in kgs
    (slot weight (type FLOAT))
    ; bmi = height/weight^2
    (slot bmi (type FLOAT))
    ; job type sedentary or manual
    (slot activityType (allowed-values sedentary light moderate active intense))
    (slot workoutType (allowed-values intense moderate))
    (slot sugarLevel (type FLOAT))
    ; Systolic is the higher number in B.P. reading
    (slot bloodPressureSystolic (type INTEGER))
    ; Diastolic is the lower number in B.P. reading
    (slot bloodPressureDiastolic (type INTEGER))
    (slot avgHR (type INTEGER))
    (slot bodyFatPercentage (type FLOAT)(default 0))
    (slot currentSleepHours (default 0))
)

(deftemplate fatLevel
    (slot personName)
    (slot FatLevelId (type INTEGER))
    (slot FatLevelDesc)
)

(deftemplate weightPlan
	(slot personName)
    (slot weightToBe (type FLOAT))
    (slot BMR (type FLOAT))
    (slot leanBodyMass (type FLOAT))
    (slot NumCalToMaint (type FLOAT)) 
    (slot newIntakeCal (type FLOAT))
    (slot newIntakeWater (type FLOAT)) ; in ounces 
    (slot totalCalBurntforkgloss (type FLOAT))   
)

(deftemplate workoutIntakePlan
	(slot personName)
    (slot calBurntPerDay)
    (slot targetHR (type INTEGER))  
    (slot targetDays (type INTEGER))
)

(deftemplate diabeticCondition
	(slot personName)
    (slot condition)
    (slot desc)    
)

(deftemplate coronaryHeartCondn
	(slot personName)
    (slot bloodPressureType)
    (slot sleepLvl)
    (slot HDriskChances)
    (slot HDriskChancesAdj)    
)

(deftemplate immediateAttn
    (slot personName)
    (slot attnDesc)
)

; Function for calculating BMI
(deffunction calcBMI(?hgt ?wgt)
  (return(/ ?wgt (* ?hgt ?hgt) ))
)

; Rule 1
; Rule for calculating BMI
(defrule calculateBMI
	?p <- (person (personName ?name))
	=>
	(bind ?bm (calcBMI ?p.height ?p.weight))
	;(printout t "BMI calculation done" crlf "BMI value = "?bm crlf)
	(modify ?p (bmi ?bm))
)

; Function for calculating BMI rating
(deffunction checkRating(?bmind)
	(if (> ?bmind 40) then
        (return 1) 
     else (if ( > ?bmind 35) then
            (return 2) 
           else (if ( > ?bmind 30) then
                (return 3) 
                else (if ( > ?bmind 25) then
                    (return 4) 
                    else (if ( > ?bmind 18.5) then
                        (return 5)
                        else
                        (return 6)
                ))))) 
)

; Rule 2
; Rule for checking BMI rating
(defrule checkBMIRating
	?p <- (person (personName ?name))
    =>
    (if (floatp ?p.bmi) then
    	(bind ?lvl (checkRating ?p.bmi))
    	;(printout t "BMI processing done" crlf "You are catergorized as level" ?lvl crlf)
    	(assert (fatLevel(personName ?name)(FatLevelId ?lvl))))
)

(deffunction asgnFatLvlDesc(?FtLvlId)
	(if (= ?FtLvlId 1) then
        (return "Obese Class III")
        else (if (= ?FtLvlId 2) then
            (return "Obese Class II")
            else (if (= ?FtLvlId  3) then
                (return "Obese Class I")
                else (if (= ?FtLvlId 4) then
                    (return "Pre-Obese")
                    else (if (= ?FtLvlId 5) then
                        (return "Normal Range")
                        else (return "Under-Weight"))))))
)

; Rule 3
; Rules for assigning FatLevel ID in fatLevel fact
(defrule assignFatLvlDesc
	?l <- (fatLevel (personName ?name))    
    => 
    (bind ?desc (asgnFatLvlDesc ?l.FatLevelId))
    ;(printout t "Fat Description Assigned to " ?name " as " ?desc crlf)
    (modify ?l (FatLevelDesc ?desc))
)

(deffunction calcFatPercent(?sex ?age ?bmi)
	(if (= (str-compare ?sex "M") 0) then
        (bind ?val (+ (* 1.2 ?bmi) (* 0.23 ?age) -16.2))
        (return ?val)
        else
        (bind ?val (+ (* 1.2 ?bmi) (* 0.23 ?age) -5.4))
        (return ?val)
        )    
) 

; Rule 4
; Calculate percent fat in the body
(defrule calcBodyFatPercent
	?p <- (person (personName ?name))
    =>
    (if (floatp ?p.bmi) then
    (bind ?val (calcFatPercent ?p.sex ?p.age ?p.bmi))
    (modify ?p (bodyFatPercentage ?val))    
        ) 
)

; Rule 5
; calculation done using Sterling Pasmore equation
(defrule calcLeanBodyMass
	?w <- (weightPlan (personName ?name))
    =>
    (if (or (> ?w.weightToBe 0)(< ?w.weightToBe 0)) then
    	(bind ?val (/ ?w.BMR 6.2583))
    	(modify ?w (leanBodyMass ?val)))    
)

; Calculate how much weight is to be lost to bring down the BMI to 18.5 (the normal range)
(deffunction wgtToBeLostGain(?h ?w ?bm)
	(if (or (< ?bm 18.5) (> ?bm 24.9)) then
        (bind ?x (* 21.7 (* ?h ?h)))
        (return (- ?w ?x))
        else
        (return 0)
        )
)

; Rule 6
; Rules for asserting the amount of weight to be lost/gained for a person
(defrule weightLossGainPlan
    ?p <- (person (personName ?name))
    =>
    (if (floatp ?p.bmi) then
    	(bind ?val (wgtToBeLostGain ?p.height ?p.weight ?p.bmi))
		;(printout t ?name " has to lose/gain approximately " (integer ?val) " kgs.")
    	(assert (weightPlan (personName ?name)(weightToBe (integer ?val)))))
)

; Function to calculate BMR
(deffunction calcBMR(?sex ?w ?h ?a)
	(if (= (str-compare ?sex "M") 0) then
    	(bind ?t1 (* 13.7 ?w))
        (bind ?t2 (* 5 ?h 100))
        (bind ?t3 (* 6.8 -1 ?a))
        (bind ?sol (+ 66 ?t1 ?t2 ?t3))
        else
        (bind ?t1 (* 9.6 ?w))
        (bind ?t2 (* 1.8 ?h 100))
        (bind ?t3 (* 4.7 -1 ?a))
        (bind ?sol (+ 655 ?t1 ?t2 ?t3))    
    )
    (return ?sol)	    
)

; Rule 7
; Rule that assigns a BMR value to individuals who have non zero weight to be
(defrule calculateBMR
    ?p1 <- (weightPlan {weightToBe != 0} (personName ?name))
    ?p2 <- (person {personName == p1.personName})
    =>
    (bind ?val (calcBMR ?p2.sex ?p2.weight ?p2.height ?p2.age))
    ;(printout t "BMR calculation complete!" crlf ?name "'s BMR = " ?val)
    (modify ?p1(BMR ?val))
)

; This formula is known as Harris Benedict Formula
(deffunction calcCalInMaint(?bmr ?type)
	(if (= (str-compare ?type "sedentary") 0) then
        (return (* 1.2 ?bmr))
        else(if (= (str-compare ?type "light") 0) then
            (return (* 1.375 ?bmr))
            else (if (= (str-compare ?type "moderate") 0) then
                (return (* 1.55 ?bmr))
                else (if (= (str-compare ?type "active") 0) then
                    (return (* 1.725 ?bmr))
                    else (return (* 1.9 ?bmr))
                    ))))    
)

; Rule 8
(defrule calcCalIntakeToMaint
	?p1 <- (weightPlan {weightToBe != 0} (personName ?name))
    ?p2 <- (person {personName == p1.personName})
    =>
    (if (floatp ?p1.BMR) then
    	(bind ?val (calcCalInMaint ?p1.BMR ?p2.activityType))
    	;(printout t "Total number of calories " ?name " needs to take to maintain your current weight " ?val crlf)
    	(modify ?p1 (NumCalToMaint ?val)))    
)


; Rule 9
(defrule calcCalIntakeBurnQty
	?p <- (weightPlan {weightToBe > 0} (personName ?name))
    =>
    (bind ?val1 (* 0.85 ?p.NumCalToMaint)) ; a person should reduce the daily requirements by 15% only
    (modify ?p (newIntakeCal ?val1))
    ; 1 kg is approximately equal to 7718 calories. 
    (bind ?val2 (* 7717.75 ?p.weightToBe))
    (modify ?p (totalCalBurntforkgloss ?val2))    
)

; formula for calculating calories expended by U.S. Army Fitness Manuals.
(deffunction calculateCalPerWorkout(?type ?weight)
	(if (= (str-compare ?type "intense") 0) then
        (return (* 0.1 90 ?weight 2.204))
    else (return (* 0.079 90 ?weight 2.2014))
        )    
)

; Rule 10
; assumption the person will run at 6 mph(moderate) or 10 mph(intense) and will only run upto a maximum of 90 minutes
; the 90 minute mark adviced by American College of Sports Medicine
(defrule createWorkoutPlan
	?p1 <- (weightPlan{weightToBe > 0} (personName ?name))
    ?p2 <- (person {personName == p1.personName})
    =>
    (bind ?val1 (calculateCalPerWorkout ?p2.workoutType ?p2.weight))
    (if (floatp ?p1.totalCalBurntforkgloss) then 
        (bind ?val2 ?p1.totalCalBurntforkgloss)
    	(bind ?targ (/ ?val2 ?val1))
    	(assert (workoutIntakePlan (personName ?name)(calBurntPerDay ?val1)(targetDays ?targ))))
)

; Rule 11
; weight gain should be done by consuming an additional 500 calories (this will help gain 1 lb per week)
(defrule calcCalIntakeGainQty
	?p <- (weightPlan {weightToBe < 0} (personName ?name))
    =>
    (modify ?p (newIntakeCal (+ 500 ?p.NumCalToMaint)))
)

(deffunction cmptTrgtDays(?wToBe ?w ?newIn)
	(return (/ (* (+ ?wToBe ?w) 7718) ?newIn))	    
)

; Rule 12
; target no. of days for weight gain
(defrule computeTrgtDaysWgtGain
    ?p1 <- (weightPlan {weightToBe < 0} (personName ?name))
    ?p2 <- (person {personName == p1.personName})
    =>
    (if (floatp ?p1.newIntakeCal) then
    	(bind ?val (cmptTrgtDays ?p1.weightToBe ?p2.weight ?p1.newIntakeCal))
    	(assert (workoutIntakePlan (personName ?name)(targetDays ?val))))
)

; Rule 13
; compute whether the patient suffers from any diabetic condition
(defrule assessDiabeticCondition 
	?p <- (person (personName ?name))
    =>
    (if (< ?p.sugarLevel 70) then
        (assert (diabeticCondition (personName ?name)(condition "low")(desc "You have very low blood sugar levels. Consult physician")))
        else (if (< ?p.sugarLevel 99) then
            (assert(diabeticCondition (personName ?name)(condition "normal")(desc "Your sugar level is normal")))
            else (if (< ?p.sugarLevel 125) then
                (assert(diabeticCondition (personName ?name)(condition "pre")(desc "You have High chances of diabetes")))
                else (assert (diabeticCondition (personName ?name)(condition "diabetic")(desc "Diabetes"))))
            )
        )    
)


(deffunction getBldPressRtng(?hgh ?low)
    (if (and (< ?hgh 120) (> ?low 80)) then
        (return "normal")
        else (if (and (< ?hgh 139) (> ?low 89)) then
            (return "prehypertension")
            else (if (and (< ?hgh 159) (> ?low 99)) then
                (return "stage1")
                    else (if (and (> ?hgh 160) (> ?low 100)) then
                        (return "stage2")
                    	else (return "abnormal")
                    ))))
)


; Rule 14
; Rule to check if the patient has a high/low blood pressure
(defrule checkBldPressLvls
	?p <- (person (personName ?name))
    =>
    (bind ?val (getBldPressRtng ?p.bloodPressureSystolic ?p.bloodPressureDiastolic))    
	(assert (coronaryHeartCondn (personName ?name)(bloodPressureType ?val)))
)


(deffunction getSleepRtng(?a ?sh ?bptype)
	(if (or (= (str-compare ?bptype "prehypertension") 0) (= (str-compare ?bptype "stage1") 0) (= (str-compare ?bptype "stage2") 0))
        then
        (if (and (< ?a 13) (< ?sh 9)) then ; school age children with less than 9 hr sleep 
            (return "bad")
            else (if (and (< ?a 17) (< ?sh 8)) then  ; teenagers with less than 8 hr sleep
                (return "bad")
                else (if (and (< ?a 25) (< ?sh 7)) then ; younger adults and mature adults with less than 7 hr sleep
                    (return "bad")
                    else (if (and (< ?a 64) (< ?sh 7)) then
                        (return "bad")
                        else (if (< ?sh 6) then ; other adults with less than 6 hr sleep
                            (return "bad")
                            else (return "ok")))
                    )))    
	else
        (return "good")	
        )
)

; Rule 15
; Standard sleep patterns as decided by sleepfoundation.org
(defrule checkStrsLvls
	?p1 <- (person(personName ?name))
    ?p2 <- (coronaryHeartCondn {personName == p1.personName})
    =>
    (bind ?val (getSleepRtng ?p1.age ?p1.currentSleepHours ?p2.bloodPressureType))  
	(modify ?p2 (sleepLvl ?val)) 
)
 
; Rule 16
(defrule chckCHDRisk
    ?p <-(coronaryHeartCondn (personName ?name))
    =>
    (if (or (= (str-compare ?p.bloodPressureType "prehypertension") 0)
                 (= (str-compare ?p.bloodPressureType "stage1") 0)
                 (= (str-compare ?p.bloodPressureType "stage2") 0))
             then
        (if (= (str-compare ?p.sleepLvl "bad") 0) then
                (modify ?p (HDriskChances "high"))
            else 
        	(modify ?p (HDriskChances "moderate")))
     else
        (modify ?p (HDriskChances "less"))
        )
)

; Rule 17
; Adjustment for obesity. Less becomes moderate and moderate becomes high if obese
(defrule adjustForObesity
	?p1 <- (coronaryHeartCondn (personName ?name))
    ?p2 <- (fatLevel {personName == p1.personName})
    =>
    (if (<= ?p2.FatLevelId 4) then
        (if (= (str-compare ?p1.HDriskChances "moderate") 0) then
            (bind ?val "high")
            else (if (= (str-compare ?p1.HDriskChances "less") 0) then
            (bind ?val "moderate")
                else (bind ?val ?p1.HDriskChances)))
    else
        (bind ?val ?p1.HDriskChances))
	(modify ?p1 (HDriskChancesAdj ?val))
)
; convert kgs to pounds function
(deffunction convKgLb(?w)
    (return (* ?w 2.2014)))
 
; Rule 18
; calculate the amount of water one should drink everyday
(defrule calcWaterQty
	?p1 <- (weightPlan (personName ?name))
    ?p2 <- (person {personName == p1.personName})
    =>
    (if (integerp ?p1.weightToBe) then
		(bind ?val1 (* 0.6667 (convKgLb ?p2.weight)))
		(modify ?p1 (newIntakeWater ?val1 ))
	)
)

(deffunction findTargetHR(?avgHR ?age ?type)
	(bind ?max (- 220 ?age))
    (if (= (str-compare type "intense")) then
        (bind ?intense 0.70)
        else
        (bind ?intense 0.40)
        )
	(bind ?val (+ ( * (- ?max ?avgHR) ?intense) ?avgHR)) 
    (return ?val)     
)

; Rule 19
; Calculate target heart rate depending on your workout type
(defrule findTargetHR
	?p1 <- (person (personName ?name))
    ?p2 <- (workoutIntakePlan {personName == p1.personName})    
	=>
    (bind ?val (findTargetHR ?p1.avgHR ?p1.age ?p1.workoutType))
    (modify ?p2 (targetHR ?val))
) 

; Rule 20
; Immediate consulting required rule
(defrule chckConsultingReq
	?p1 <- (fatLevel (personName ?name))
    ?p2 <- (diabeticCondition {personName == p1.personName}) 
    ?p3 <- (coronaryHeartCondn {personName == p1.personName}) 
    => 
    (if (< ?p1.FatLevelId 4) then ;obese class II and I
        (if (= (str-compare ?p2.condition "diabetic") 0) then
            (if (= (str-compare ?p3.HDriskChancesAdj "high") 0) then
                (assert (immediateAttn (personName ?name)(attnDesc "immediate")))))) 
)