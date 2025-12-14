-- Migration: Update Interview Questions to "Friendly Coach" Mode (The Bible)
-- Date: 2025-12-14

-- 1. Personal Information
UPDATE ai_interview_flow SET question_es = 'Copia tus apellidos exactamente como salen en tu pasaporte. Si tienes dos, pon los dos. Si en tu pasaporte sale solo uno, pon solo uno.' WHERE field_key = 'ds160_data.personal.surnames';
UPDATE ai_interview_flow SET question_es = 'Tus nombres de pila. Igualito al pasaporte.' WHERE field_key = 'ds160_data.personal.given_names';
UPDATE ai_interview_flow SET question_es = 'Si tu nombre tiene letras raras (como en chino o árabe), aquí se escriben. Para nosotros los latinos, casi siempre es "No aplica", a menos que el sistema te deje poner tildes.' WHERE field_key = 'ds160_data.personal.native_name';
UPDATE ai_interview_flow SET question_es = '¿Antes te llamabas diferente? (Común en mujeres casadas que usaban apellido de soltera, o nombres religiosos/profesionales). Si siempre te has llamado igual, pon "No".' WHERE field_key = 'ds160_data.personal.other_names';
UPDATE ai_interview_flow SET question_es = '¿Tienes un telecódigo? (Esto son unos números para nombres asiáticos. Tú ponle "No").' WHERE field_key = 'ds160_data.personal.telecode_name';
UPDATE ai_interview_flow SET question_es = '¿En tu pasaporte dice Masculino (M) o Femenino (F)?' WHERE field_key = 'ds160_data.personal.sex';
UPDATE ai_interview_flow SET question_es = '¿Cuál es tu situación amorosa legal hoy? (Soltero, Casado, Divorciado, Viudo, Unión Libre). Ojo: Si pones "Unión Libre" o "Casado", pediré datos de tu pareja.' WHERE field_key = 'ds160_data.personal.marital_status';

-- Grouped Date/Place of Birth Trigger (Applied to DOB, hoping Smart Save catches the rest)
UPDATE ai_interview_flow SET question_es = 'Dime tu día, mes, año, ciudad, estado y país donde naciste.' WHERE field_key = 'ds160_data.personal.dob';
-- Fallbacks for individual fields if not caught in the group answer
UPDATE ai_interview_flow SET question_es = '¿En qué ciudad naciste?' WHERE field_key = 'ds160_data.personal.city_of_birth';
UPDATE ai_interview_flow SET question_es = '¿En qué estado o provincia naciste? (Si no aplica, pon "No aplica")' WHERE field_key = 'ds160_data.personal.state_of_birth';
UPDATE ai_interview_flow SET question_es = '¿En qué país naciste?' WHERE field_key = 'ds160_data.personal.country_of_birth';

-- 2. Nationality & ID
UPDATE ai_interview_flow SET question_es = '¿De qué país es el pasaporte con el que viajas?' WHERE field_key = 'ds160_data.personal.nationality';
UPDATE ai_interview_flow SET question_es = '¿Tienes pasaporte de otro país? (Ej: Eres colombiano pero también tienes ciudadanía española). Si sí, hay que ponerlo.' WHERE field_key = 'ds160_data.personal.other_nationalities';
-- Missing logic for 'resident of other country' mapping? Assuming field name:
UPDATE ai_interview_flow SET question_es = '¿Eres residente permanente de otro país donde no eres ciudadano? (Ej: Venezolano viviendo en Chile).' WHERE field_key = 'ds160_data.personal.permanent_resident_other';
UPDATE ai_interview_flow SET question_es = 'Tu número de Identificación Nacional (Cédula, DNI, CURP, DUI, etc).' WHERE field_key = 'ds160_data.personal.national_id';
UPDATE ai_interview_flow SET question_es = '¿Tienes Número de Seguro Social de EE.UU.? Si nunca has vivido ni trabajado allá legalmente, marca "Does Not Apply". No inventes.' WHERE field_key = 'ds160_data.personal.us_ssn';
UPDATE ai_interview_flow SET question_es = '¿Tienes Tax ID de EE.UU.? (Si no aplica, di "No aplica").' WHERE field_key = 'ds160_data.personal.us_tax_id';

-- 3. Address & Contact
UPDATE ai_interview_flow SET question_es = '¿Dónde duermes todas las noches? (Calle, número de casa y barrio/colonia).' WHERE field_key = 'ds160_data.contact.address_home';
UPDATE ai_interview_flow SET question_es = '¿El correo te llega a esa misma casa? (Si dices "No", te pediré otra dirección).' WHERE field_key = 'ds160_data.contact.mailing_differs';
UPDATE ai_interview_flow SET question_es = 'Dame tu número de celular (Principal).' WHERE field_key = 'ds160_data.contact.phone_primary';
UPDATE ai_interview_flow SET question_es = '¿Tienes teléfono de casa? (Secundario, opcional).' WHERE field_key = 'ds160_data.contact.phone_secondary';
UPDATE ai_interview_flow SET question_es = '¿Tienes teléfono de oficina? (Trabajo, opcional).' WHERE field_key = 'ds160_data.contact.phone_work';
UPDATE ai_interview_flow SET question_es = 'El email que usas de verdad, porque ahí te pueden mandar avisos.' WHERE field_key = 'ds160_data.contact.email_address';
UPDATE ai_interview_flow SET question_es = '¡Importante! ¿Qué redes sociales has usado en los últimos 5 años? (Facebook, Instagram, etc). Solo necesito tu Nombre de Usuario.' WHERE field_key = 'ds160_data.contact.social_media';

-- 4. Passport
-- Smart Default handles Document Type, but updating text just in case
UPDATE ai_interview_flow SET question_es = 'Casi siempre es "Regular". ¿Qué tipo de pasaporte tienes?' WHERE field_key = 'ds160_data.passport.document_type';
UPDATE ai_interview_flow SET question_es = 'El número que viene perforado o impreso en la hoja de tus datos.' WHERE field_key = 'ds160_data.passport.passport_number';
UPDATE ai_interview_flow SET question_es = 'Número de Libreta (Book Number). Si tu pasaporte no lo dice explícitamente, pon "No aplica".' WHERE field_key = 'ds160_data.passport.book_number';
-- Grouped Expiration/Issuance
UPDATE ai_interview_flow SET question_es = '¿Cuándo te lo dieron, cuándo se vence y en qué ciudad/país te lo dieron?' WHERE field_key = 'ds160_data.passport.issuance_date';
-- Fallbacks
UPDATE ai_interview_flow SET question_es = '¿Cuándo vence tu pasaporte?' WHERE field_key = 'ds160_data.passport.expiration_date';
UPDATE ai_interview_flow SET question_es = '¿Qué país/autoridad emitió el pasaporte?' WHERE field_key = 'ds160_data.passport.issuing_country';

UPDATE ai_interview_flow SET question_es = 'Sé honesto. ¿Alguna vez has perdido un pasaporte o te lo han robado?' WHERE field_key = 'ds160_data.passport.lost_passport';

-- 5. Trip
UPDATE ai_interview_flow SET question_es = 'Aquí eliges a qué vas. (Ej: Turismo, Negocios, Estudio).' WHERE field_key = 'ds160_data.travel.purpose_code';
-- Specify is usually sub-logic, kept simple or handled by options.
UPDATE ai_interview_flow SET question_es = '¿Tienes planes fijos de viaje (vuelo comprado)? Si no, pon "No" y dame una fecha aproximada.' WHERE field_key = 'ds160_data.travel.specific_plan';
UPDATE ai_interview_flow SET question_es = 'Fecha estimada de llegada.' WHERE field_key = 'ds160_data.travel.arrival_date';
UPDATE ai_interview_flow SET question_es = '¿Cuánto tiempo te quieres quedar? (Ej: 2 semanas).' WHERE field_key = 'ds160_data.travel.length_of_stay';
UPDATE ai_interview_flow SET question_es = '¿Dónde te vas a quedar? (Nombre de hotel o dirección de familiar).' WHERE field_key = 'ds160_data.travel.address_us';
UPDATE ai_interview_flow SET question_es = '¿Quién paga el viaje? (Tú mismo, familiar, empresa...).' WHERE field_key = 'ds160_data.travel.paying_entity';

-- 6. Companions
UPDATE ai_interview_flow SET question_es = '¿Vas con alguien? (Esposa, hijos, amigos).' WHERE field_key = 'ds160_data.travel.companions';
UPDATE ai_interview_flow SET question_es = '¿Vas en grupo organizado? (Equipo deportivo, tour, orquesta). Si es solo familia, pon "No".' WHERE field_key = 'ds160_data.travel.companions_group';

-- 7. Previous Travel
UPDATE ai_interview_flow SET question_es = '¿Has estado en EE.UU. antes? (Si sí, dime cuándo y cuánto tiempo las últimas 5 veces).' WHERE field_key = 'ds160_data.travel.previous_us_travel';
UPDATE ai_interview_flow SET question_es = '¿Tienes licencia de conducir de EE.UU.?' WHERE field_key = 'ds160_data.travel.has_us_driver_license';
UPDATE ai_interview_flow SET question_es = '¿Has tenido visa de EE.UU. antes? (Si sí, busca el número rojo y la fecha).' WHERE field_key = 'ds160_data.travel.previous_visa';
UPDATE ai_interview_flow SET question_es = '¡Súper importante! ¿Alguna vez te han negado una visa? (Aunque fuera hace 20 años, pon SÍ y explica).' WHERE field_key = 'ds160_data.travel.refused_entry';
UPDATE ai_interview_flow SET question_es = '¿Algún familiar o empresa metió papeles para pedirte la Residencia (Green Card)?' WHERE field_key = 'ds160_data.travel.petition_filed';

-- 8. US Contact
UPDATE ai_interview_flow SET question_es = '¿A quién vas a ver? (Nombre de persona u hotel). Si es hotel, en Nombre pon "Do Not Know".' WHERE field_key = 'ds160_data.us_contact.person_name';

-- 9. Family
UPDATE ai_interview_flow SET question_es = 'Nombres y fechas de nacimiento de tus papás. (Aunque hayan fallecido).' WHERE field_key = 'ds160_data.family.father_name';
-- Checking if mother needs update or simply flows
UPDATE ai_interview_flow SET question_es = '¿Tu padre está en EE.UU.? (Si sí, ¿es ciudadano, residente o visita?).' WHERE field_key = 'ds160_data.family.father_in_us';
UPDATE ai_interview_flow SET question_es = '¿Tu madre está en EE.UU.?' WHERE field_key = 'ds160_data.family.mother_in_us';
UPDATE ai_interview_flow SET question_es = '¿Tienes otros parientes inmediatos en EE.UU. (Esposo/a, hijos, hermanos)?' WHERE field_key = 'ds160_data.family.relatives_us';
UPDATE ai_interview_flow SET question_es = '¿Tienes otros parientes allá? (Tíos, primos, abuelos).' WHERE field_key = 'ds160_data.family.relatives_other';

-- Spouse
UPDATE ai_interview_flow SET question_es = 'Datos completos de tu pareja: Nombre, fecha, lugar de nacimiento y nacionalidad.' WHERE field_key = 'ds160_data.spouse.full_name';

-- 10. Work
UPDATE ai_interview_flow SET question_es = '¿Qué eres? (Ocupación actual: Agricultor, Negocios, Estudiante, Ama de casa...).' WHERE field_key = 'ds160_data.work_history.primary_occupation';
UPDATE ai_interview_flow SET question_es = 'Datos del trabajo/escuela: Nombre, dirección, teléfono y fecha de inicio.' WHERE field_key = 'ds160_data.work_history.current_employer';
UPDATE ai_interview_flow SET question_es = 'Cuánto ganas al mes en tu moneda local. (No lo conviertas a dólares).' WHERE field_key = 'ds160_data.work_history.monthly_income';
UPDATE ai_interview_flow SET question_es = 'Describe tus tareas brevemente (Qué haces).' WHERE field_key = 'ds160_data.work_history.duties';
UPDATE ai_interview_flow SET question_es = '¿Has tenido otros trabajos en los últimos 5 años?' WHERE field_key = 'ds160_data.work_history.previous_employed';
UPDATE ai_interview_flow SET question_es = '¿Fuiste a la secundaria o universidad? (Nombre, dirección, fechas).' WHERE field_key = 'ds160_data.work_history.previous_educational';
UPDATE ai_interview_flow SET question_es = '¿Perteneces a alguna tribu o clan indígena reconocido?' WHERE field_key = 'ds160_data.work_history.clan_tribe';
UPDATE ai_interview_flow SET question_es = '¿Qué idiomas hablas?' WHERE field_key = 'ds160_data.work_history.languages';
UPDATE ai_interview_flow SET question_es = '¿A qué países has viajado en los últimos 5 años?' WHERE field_key = 'ds160_data.work_history.traveled_countries';

-- 11. Security (Simplifying to the 99% rule)
UPDATE ai_interview_flow SET question_es = '¿Tienes tuberculosis o enfermedades muy contagiosas?' WHERE field_key = 'ds160_data.security_questions.disease';
UPDATE ai_interview_flow SET question_es = '¿Tienes desordenes mentales violentos?' WHERE field_key = 'ds160_data.security_questions.disorder';
UPDATE ai_interview_flow SET question_es = '¿Eres drogadicto?' WHERE field_key = 'ds160_data.security_questions.drug_user';
UPDATE ai_interview_flow SET question_es = '¿Alguna vez te arrestaron (aunque te soltaran)?' WHERE field_key = 'ds160_data.security_questions.arrested';
UPDATE ai_interview_flow SET question_es = '¿Vienes a prostituirte?' WHERE field_key = 'ds160_data.security_questions.prostitution';
UPDATE ai_interview_flow SET question_es = '¿Vienes a espiar o hacer terrorismo?' WHERE field_key = 'ds160_data.security_questions.terrorist_activity';
UPDATE ai_interview_flow SET question_es = '¿Alguna vez mentiste para conseguir una visa?' WHERE field_key = 'ds160_data.security_questions.visa_fraud';
