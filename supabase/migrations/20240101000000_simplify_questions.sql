-- Simplification of DS-160 Questions (Child-Like Mode)

-- 1. Configuración
UPDATE ai_interview_flow SET question_es = 'Hola! 👋 Para empezar, ¿en qué ciudad quieres tener tu cita para la visa?' WHERE field_key = 'application_location';
UPDATE ai_interview_flow SET question_es = 'Si perdemos tu formulario, necesito una clave secreta. ¿Cómo se llamaba tu primera mascota o cuál es el apellido de soltera de tu mamá?' WHERE field_key = 'security_question';

-- 2. Información Personal
UPDATE ai_interview_flow SET question_es = '¿Cómo te llamas? Escribe tus nombres y apellidos exactamente como salen en tu pasaporte.' WHERE field_key = 'surnames'; -- Assuming surnames covers both for simplicity in this update, or split if needed. Ideally we update specific fields.
UPDATE ai_interview_flow SET question_es = '¿Alguna vez has usado otro nombre? Por ejemplo, ¿tu apellido de soltera o algún nombre religioso?' WHERE field_key = 'other_names_used';
UPDATE ai_interview_flow SET question_es = '¿Cuál es tu estado civil actual? (Casado, Soltero, Divorciado...)' WHERE field_key = 'marital_status';
UPDATE ai_interview_flow SET question_es = '¿Cuándo naciste y en qué ciudad?' WHERE field_key = 'dob';

-- 3. Pasaporte
UPDATE ai_interview_flow SET question_es = 'Toma tu pasaporte y dime el número que aparece arriba a la derecha.' WHERE field_key = 'passport_number';
UPDATE ai_interview_flow SET question_es = '¿Cuándo te entregaron ese pasaporte y cuándo se vence?' WHERE field_key = 'passport_dates'; -- Composite field assumption
UPDATE ai_interview_flow SET question_es = '¿Alguna vez se te ha perdido o te han robado un pasaporte?' WHERE field_key = 'lost_passport';

-- 4. Viaje
UPDATE ai_interview_flow SET question_es = '¿A qué vas a Estados Unidos? ¿De vacaciones, negocios o estudios?' WHERE field_key = 'travel_purpose';
UPDATE ai_interview_flow SET question_es = '¿Ya tienes fecha para el viaje o es solo una fecha estimada?' WHERE field_key = 'travel_dates';
UPDATE ai_interview_flow SET question_es = '¿Sabes dónde te vas a quedar? Si es un hotel o casa de un amigo, dime la dirección.' WHERE field_key = 'us_address';
UPDATE ai_interview_flow SET question_es = '¿Quién paga este viaje? ¿Tú mismo u otra persona?' WHERE field_key = 'trip_payer';

-- 5. Familia
UPDATE ai_interview_flow SET question_es = '¿Cómo se llaman tus papás y cuándo nacieron? (Aunque hayan fallecido).' WHERE field_key = 'parents_info';
UPDATE ai_interview_flow SET question_es = '¿Tienes algún familiar directo viviendo allá? (Hijos, hermanos, papás o esposo/a).' WHERE field_key = 'us_relatives';

-- 6. Trabajo
UPDATE ai_interview_flow SET question_es = '¿En qué trabajas actualmente? Dime el nombre de la empresa.' WHERE field_key = 'primary_occupation';
UPDATE ai_interview_flow SET question_es = '¿Cuánto ganas al mes aproximadamente? (En tu moneda local).' WHERE field_key = 'monthly_income';
UPDATE ai_interview_flow SET question_es = 'Cuéntame brevemente qué haces en tu trabajo día a día.' WHERE field_key = 'job_duties';
UPDATE ai_interview_flow SET question_es = '¿Has tenido otro trabajo en los últimos 5 años? Dime dónde.' WHERE field_key = 'previous_employment';

-- 7. Seguridad
UPDATE ai_interview_flow SET question_es = '¿Tienes alguna enfermedad contagiosa grave actualmente? (Como tuberculosis).' WHERE field_key = 'security_health';
UPDATE ai_interview_flow SET question_es = '¿Sufres de algún problema mental que pueda ser peligroso para ti o para otros?' WHERE field_key = 'security_mental';
UPDATE ai_interview_flow SET question_es = '¿Has tenido problemas de adicción a las drogas alguna vez?' WHERE field_key = 'security_addiction';
UPDATE ai_interview_flow SET question_es = 'Muy importante: ¿Alguna vez has tenido problemas con la policía? ¿Te han arrestado o detenido, aunque te hayan soltado después?' WHERE field_key = 'security_arrest';
UPDATE ai_interview_flow SET question_es = '¿Alguna vez has estado involucrado en venta o tráfico de drogas?' WHERE field_key = 'security_controlled_substances';
UPDATE ai_interview_flow SET question_es = '¿Tienes alguna intención de hacer daño, espiar o participar en actos terroristas en EE.UU.?' WHERE field_key = 'security_terrorism';
UPDATE ai_interview_flow SET question_es = '¿Alguna vez has mentido para intentar conseguir una visa o entrar a EE.UU.?' WHERE field_key = 'security_fraud';
UPDATE ai_interview_flow SET question_es = '¿Alguna vez te han deportado o te han negado la entrada en el aeropuerto?' WHERE field_key = 'security_deportation';
