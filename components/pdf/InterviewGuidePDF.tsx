import { Document, Page, Text, View, StyleSheet, Image, Font } from "@react-pdf/renderer";

// Define styles for a "Government Handbook" look (Dense, Times New Roman)
const styles = StyleSheet.create({
    page: {
        flexDirection: "column",
        backgroundColor: "#FFFFFF",
        paddingTop: 30,
        paddingBottom: 40,
        paddingHorizontal: 40,
        fontFamily: "Times-Roman",
    },
    header: {
        borderBottomWidth: 2,
        borderBottomColor: "#000000",
        marginBottom: 15,
        paddingBottom: 10,
        flexDirection: "row",
        justifyContent: "space-between",
        alignItems: "center",
    },
    headerLeft: {
        flexDirection: "row",
        alignItems: "center",
    },
    logo: {
        width: 45,
        height: 45,
        marginRight: 10,
        objectFit: "contain",
    },
    headerTitle: {
        fontSize: 16,
        fontFamily: "Times-Bold",
        textTransform: "uppercase",
        color: "#000000",
    },
    headerSubtitle: {
        fontSize: 9,
        fontFamily: "Times-Roman",
        color: "#333333",
        marginTop: 2,
    },
    metaBox: {
        borderWidth: 1,
        borderColor: "#000000",
        padding: 5,
        alignItems: "center",
    },
    metaText: {
        fontSize: 7,
        fontFamily: "Times-Bold",
        textTransform: "uppercase",
    },
    // Dense Content Styles
    sectionTitle: {
        fontSize: 12,
        fontFamily: "Times-Bold",
        backgroundColor: "#E5E7EB",
        padding: 4,
        marginTop: 10,
        marginBottom: 5,
        textTransform: "uppercase",
        borderLeftWidth: 3,
        borderLeftColor: "#003366",
    },
    subTitle: {
        fontSize: 10,
        fontFamily: "Times-Bold",
        marginTop: 6,
        marginBottom: 2,
        color: "#003366",
    },
    text: {
        fontSize: 9,
        lineHeight: 1.4,
        textAlign: "justify",
        marginBottom: 4,
    },
    bold: {
        fontFamily: "Times-Bold",
    },
    // Grid/Columns
    row: {
        flexDirection: "row",
        gap: 10,
    },
    column: {
        flex: 1,
    },
    // Lists
    listItem: {
        flexDirection: "row",
        marginBottom: 2,
    },
    bullet: {
        width: 10,
        fontSize: 9,
        fontFamily: "Times-Bold",
    },
    listContent: {
        flex: 1,
        fontSize: 9,
        lineHeight: 1.4,
    },
    // Warning/Alert
    alertBox: {
        borderWidth: 1,
        borderColor: "#DC2626",
        backgroundColor: "#FEF2F2",
        padding: 8,
        marginVertical: 5,
    },
    alertTitle: {
        fontSize: 9,
        fontFamily: "Times-Bold",
        color: "#991B1B",
        marginBottom: 2,
        textTransform: "uppercase",
    },
    // Footer
    footer: {
        position: "absolute",
        bottom: 20,
        left: 40,
        right: 40,
        borderTopWidth: 1,
        borderTopColor: "#CCCCCC",
        paddingTop: 5,
        flexDirection: "row",
        justifyContent: "space-between",
    },
    footerText: {
        fontSize: 7,
        color: "#666666",
    },
    // Images
    inlineImage: {
        width: "100%",
        height: 100,
        objectFit: "contain",
        marginVertical: 5,
        borderWidth: 1,
        borderColor: "#CCCCCC",
    }
});

export const InterviewGuidePDF = () => (
    <Document>
        {/* PAGE 1: PREPARATION & PROTOCOLS */}
        <Page size="A4" style={styles.page}>
            {/* Header */}
            <View style={styles.header}>
                <View style={styles.headerLeft}>
                    <Image src="/logo.png" style={styles.logo} />
                    <View>
                        <Text style={styles.headerTitle}>US Visa Processing Center</Text>
                        <Text style={styles.headerSubtitle}>MANUAL OFICIAL DE PREPARACIÓN CONSULAR (B1/B2)</Text>
                    </View>
                </View>
                <View style={styles.metaBox}>
                    <Text style={styles.metaText}>EDICIÓN 2025</Text>
                    <Text style={styles.metaText}>REF: USVPC-INT-01</Text>
                </View>
            </View>

            <Text style={[styles.text, { fontStyle: "italic", marginBottom: 10 }]}>
                Este documento contiene información crítica y actualizada para su entrevista. Léalo en su totalidad.
                El incumplimiento de estos protocolos puede resultar en la denegación automática de su visa bajo la sección 214(b).
            </Text>

            {/* CRITICAL UPDATES 2025 */}
            <View style={styles.alertBox}>
                <Text style={styles.alertTitle}>⚠️ ACTUALIZACIONES CRÍTICAS 2025</Text>
                <View style={styles.listItem}>
                    <Text style={styles.bullet}>•</Text>
                    <Text style={styles.listContent}>
                        <Text style={styles.bold}>Coincidencia de Código de Barras:</Text> El código de barras de su hoja de confirmación DS-160
                        DEBE coincidir exactamente con el de su cita. Si actualizó su formulario, debe actualizar su cita al menos 72 horas antes.
                    </Text>
                </View>
                <View style={styles.listItem}>
                    <Text style={styles.bullet}>•</Text>
                    <Text style={styles.listContent}>
                        <Text style={styles.bold}>Entrevistas Presenciales:</Text> La mayoría de las exenciones de entrevista han sido eliminadas.
                        Prepárese para una entrevista personal obligatoria.
                    </Text>
                </View>
            </View>

            <View style={styles.row}>
                {/* COLUMN 1 */}
                <View style={styles.column}>
                    <Text style={styles.sectionTitle}>1. DOCUMENTACIÓN OBLIGATORIA</Text>
                    <Text style={styles.text}>Organice estos documentos en una carpeta transparente, en este orden exacto:</Text>

                    <View style={styles.listItem}><Text style={styles.bullet}>1.</Text><Text style={styles.listContent}><Text style={styles.bold}>Pasaporte Vigente:</Text> Mínimo 6 meses de validez futura. Lleve también pasaportes anteriores con visas.</Text></View>
                    <View style={styles.listItem}><Text style={styles.bullet}>2.</Text><Text style={styles.listContent}><Text style={styles.bold}>Hoja de Confirmación DS-160:</Text> La página con el código de barras (impresión láser clara).</Text></View>
                    <View style={styles.listItem}><Text style={styles.bullet}>3.</Text><Text style={styles.listContent}><Text style={styles.bold}>Confirmación de Cita:</Text> El documento que muestra la fecha y hora.</Text></View>
                    <View style={styles.listItem}><Text style={styles.bullet}>4.</Text><Text style={styles.listContent}><Text style={styles.bold}>Fotografía Reciente:</Text> 5x5 cm, fondo blanco, sin lentes (aunque la haya subido digitalmente).</Text></View>

                    <Text style={styles.subTitle}>Documentos de Soporte (Evidencia):</Text>
                    <View style={styles.listItem}><Text style={styles.bullet}>•</Text><Text style={styles.listContent}>Estados de cuenta bancarios (últimos 3 meses).</Text></View>
                    <View style={styles.listItem}><Text style={styles.bullet}>•</Text><Text style={styles.listContent}>Carta de trabajo (antigüedad, cargo, salario).</Text></View>
                    <View style={styles.listItem}><Text style={styles.bullet}>•</Text><Text style={styles.listContent}>Títulos de propiedad (casa, vehículo, terrenos).</Text></View>
                    <View style={styles.listItem}><Text style={styles.bullet}>•</Text><Text style={styles.listContent}>Actas de nacimiento/matrimonio (lazos familiares).</Text></View>

                    <Image src="/interview-documents.png" style={styles.inlineImage} />
                </View>

                {/* COLUMN 2 */}
                <View style={styles.column}>
                    <Text style={styles.sectionTitle}>2. PROTOCOLO DE LLEGADA</Text>
                    <Image src="/interview-arrival.png" style={styles.inlineImage} />

                    <View style={styles.listItem}><Text style={styles.bullet}>•</Text><Text style={styles.listContent}><Text style={styles.bold}>Hora Exacta:</Text> Llegue 30 minutos antes. Ni más, ni menos.</Text></View>
                    <View style={styles.listItem}><Text style={styles.bullet}>•</Text><Text style={styles.listContent}><Text style={styles.bold}>Seguridad:</Text> Pasará por un control tipo aeropuerto. Cinturones fuera, bolsillos vacíos.</Text></View>

                    <Text style={styles.subTitle}>🚫 ARTÍCULOS ESTRICTAMENTE PROHIBIDOS</Text>
                    <Text style={styles.text}>El ingreso con estos objetos causará la pérdida de su cita:</Text>
                    <View style={styles.listItem}><Text style={styles.bullet}>×</Text><Text style={styles.listContent}>Celulares, Smartwatches, Audífonos, USBs.</Text></View>
                    <View style={styles.listItem}><Text style={styles.bullet}>×</Text><Text style={styles.listContent}>Mochilas grandes (solo carpetas de mano).</Text></View>
                    <View style={styles.listItem}><Text style={styles.bullet}>×</Text><Text style={styles.listContent}>Alimentos, bebidas, encendedores, armas.</Text></View>
                    <Image src="/interview-prohibited.png" style={[styles.inlineImage, { height: 60 }]} />

                    <Text style={styles.sectionTitle}>3. CÓDIGO DE VESTIMENTA</Text>
                    <Text style={styles.text}><Text style={styles.bold}>Objetivo:</Text> Proyectar estabilidad y seriedad.</Text>
                    <View style={styles.listItem}><Text style={styles.bullet}>•</Text><Text style={styles.listContent}>Hombres: Camisa, pantalón de vestir. Afeitado o barba arreglada.</Text></View>
                    <View style={styles.listItem}><Text style={styles.bullet}>•</Text><Text style={styles.listContent}>Mujeres: Ropa formal de oficina. Maquillaje discreto.</Text></View>
                </View>
            </View>

            <View style={styles.footer}>
                <Text style={styles.footerText}>US Visa Processing Center • Material Confidencial de Preparación</Text>
                <Text style={styles.footerText}>Página 1 de 2</Text>
            </View>
        </Page>

        {/* PAGE 2: THE INTERVIEW & STRATEGY */}
        <Page size="A4" style={styles.page}>
            <View style={styles.header}>
                <View style={styles.headerLeft}>
                    <Text style={styles.headerTitle}>LA ENTREVISTA: ESTRATEGIA Y RESPUESTAS</Text>
                </View>
                <View style={styles.metaBox}><Text style={styles.metaText}>FASE CRÍTICA</Text></View>
            </View>

            <View style={styles.row}>
                <View style={styles.column}>
                    <Text style={styles.sectionTitle}>4. DINÁMICA DE LA ENTREVISTA</Text>
                    <Image src="/interview-speaking.png" style={styles.inlineImage} />
                    <Text style={styles.text}>
                        La entrevista dura entre 2 y 5 minutos. El oficial asume que usted es un inmigrante potencial (Sección 214b)
                        hasta que usted demuestre lo contrario. Su trabajo es convencerlo de que regresará a su país.
                    </Text>
                    <Text style={styles.subTitle}>Reglas de Oro:</Text>
                    <View style={styles.listItem}><Text style={styles.bullet}>1.</Text><Text style={styles.listContent}><Text style={styles.bold}>VERDAD ABSOLUTA:</Text> Nunca mienta. Un fraude es permanente.</Text></View>
                    <View style={styles.listItem}><Text style={styles.bullet}>2.</Text><Text style={styles.listContent}><Text style={styles.bold}>CONCISIÓN:</Text> Responda solo lo que se pregunta. No divague.</Text></View>
                    <View style={styles.listItem}><Text style={styles.bullet}>3.</Text><Text style={styles.listContent}><Text style={styles.bold}>CONTACTO VISUAL:</Text> Mire al oficial a los ojos, no al vidrio.</Text></View>
                    <View style={styles.listItem}><Text style={styles.bullet}>4.</Text><Text style={styles.listContent}><Text style={styles.bold}>COHERENCIA:</Text> Sus respuestas deben coincidir con su DS-160.</Text></View>
                </View>

                <View style={styles.column}>
                    <Text style={styles.sectionTitle}>5. PREGUNTAS FRECUENTES Y RESPUESTAS</Text>

                    <Text style={styles.subTitle}>P: ¿A qué va a los Estados Unidos?</Text>
                    <Text style={styles.text}><Text style={styles.bold}>R:</Text> "Turismo y compras en Miami por 10 días" o "A visitar Disney con mi familia". Sea específico.</Text>

                    <Text style={styles.subTitle}>P: ¿Cuánto tiempo se quedará?</Text>
                    <Text style={styles.text}><Text style={styles.bold}>R:</Text> "10 días, del 15 al 25 de agosto". (Debe coincidir con sus vacaciones laborales).</Text>

                    <Text style={styles.subTitle}>P: ¿A qué se dedica / En qué trabaja?</Text>
                    <Text style={styles.text}><Text style={styles.bold}>R:</Text> "Soy Ingeniero Civil en la empresa X desde hace 5 años". (Muestre estabilidad).</Text>

                    <Text style={styles.subTitle}>P: ¿Tiene familiares en EE.UU.?</Text>
                    <Text style={styles.text}><Text style={styles.bold}>R:</Text> Diga la verdad. Si son residentes legales, dígalo. Si están indocumentados, consulte con su asesor antes.</Text>

                    <Text style={styles.subTitle}>P: ¿Quién paga su viaje?</Text>
                    <Text style={styles.text}><Text style={styles.bold}>R:</Text> "Yo mismo con mis ahorros". (Mejor respuesta). Si paga un tercero, explique claramente por qué.</Text>
                </View>
            </View>

            <Text style={styles.sectionTitle}>6. RESULTADOS POSIBLES (LOS COLORES)</Text>
            <View style={styles.row}>
                <View style={styles.column}>
                    <Text style={[styles.subTitle, { color: "#059669" }]}>VISA APROBADA</Text>
                    <Text style={styles.text}>El oficial se quedará con su pasaporte y le dirá "Su visa ha sido aprobada". Llegará por DHL en 2-4 semanas.</Text>
                </View>
                <View style={styles.column}>
                    <Text style={[styles.subTitle, { color: "#DC2626" }]}>HOJA BLANCA (214b)</Text>
                    <Text style={styles.text}>Denegación por falta de lazos. No demostró suficiente arraigo. Puede volver a aplicar cuando su situación cambie.</Text>
                </View>
                <View style={styles.column}>
                    <Text style={[styles.subTitle, { color: "#D97706" }]}>HOJA AZUL/ROSA (221g)</Text>
                    <Text style={styles.text}>Proceso Administrativo. Requieren más documentos o tiempo para verificar información. Siga las instrucciones del papel.</Text>
                </View>
            </View>

            <View style={{ marginTop: 20, borderTopWidth: 1, borderColor: "#CCCCCC", paddingTop: 10 }}>
                <Text style={{ fontSize: 8, textAlign: "center", fontStyle: "italic" }}>
                    "La preparación no garantiza la visa, pero es la mejor herramienta para obtenerla."
                </Text>
                <Text style={{ fontSize: 10, textAlign: "center", fontFamily: "Times-Bold", marginTop: 5 }}>
                    US Visa Processing Center
                </Text>
            </View>

            <View style={styles.footer}>
                <Text style={styles.footerText}>US Visa Processing Center • Material Confidencial de Preparación</Text>
                <Text style={styles.footerText}>Página 2 de 2</Text>
            </View>
        </Page>
    </Document>
);
