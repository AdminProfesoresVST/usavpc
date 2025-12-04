import { Document, Page, Text, View, StyleSheet, Image, Font } from "@react-pdf/renderer";

// Define styles for a professional letterhead look with Government Style (Times New Roman)
const styles = StyleSheet.create({
    page: {
        flexDirection: "column",
        backgroundColor: "#FFFFFF",
        paddingTop: 0,
        paddingBottom: 40,
        paddingHorizontal: 40,
        fontFamily: "Times-Roman", // Government Standard
    },
    headerBackground: {
        backgroundColor: "#003366", // Trust Navy
        height: 80,
        marginHorizontal: -40, // Stretch to edges
        marginBottom: 30,
        paddingHorizontal: 40,
        flexDirection: "row",
        alignItems: "center",
        justifyContent: "space-between",
    },
    headerTitle: {
        color: "#FFFFFF",
        fontSize: 18,
        fontWeight: "bold",
        textTransform: "uppercase",
        letterSpacing: 1,
        fontFamily: "Times-Bold",
    },
    headerSubtitle: {
        color: "#E5E7EB",
        fontSize: 10,
        marginTop: 4,
        fontFamily: "Times-Roman",
    },
    section: {
        marginBottom: 20,
    },
    sectionTitle: {
        fontSize: 14,
        color: "#003366",
        borderBottomWidth: 1,
        borderBottomColor: "#003366",
        marginBottom: 10,
        paddingBottom: 4,
        fontWeight: "bold",
        textTransform: "uppercase",
        fontFamily: "Times-Bold",
    },
    paragraph: {
        fontSize: 11,
        color: "#000000", // Pure black for gov docs
        lineHeight: 1.6,
        marginBottom: 8,
        textAlign: "justify",
        fontFamily: "Times-Roman",
    },
    bulletContainer: {
        marginLeft: 15,
        marginBottom: 8,
    },
    bulletItem: {
        flexDirection: "row",
        marginBottom: 4,
    },
    bulletPoint: {
        width: 10,
        fontSize: 11,
        color: "#000000",
        fontFamily: "Times-Bold",
    },
    bulletText: {
        fontSize: 11,
        color: "#000000",
        lineHeight: 1.6,
        flex: 1,
        fontFamily: "Times-Roman",
    },
    warningBox: {
        marginTop: 15,
        padding: 15,
        backgroundColor: "#FEF2F2",
        borderLeftWidth: 4,
        borderLeftColor: "#DC2626",
        borderRadius: 4,
    },
    warningTitle: {
        fontSize: 12,
        color: "#991B1B",
        fontWeight: "bold",
        marginBottom: 6,
        textTransform: "uppercase",
        fontFamily: "Times-Bold",
    },
    warningText: {
        fontSize: 10,
        color: "#7F1D1D",
        lineHeight: 1.5,
        fontFamily: "Times-Roman",
    },
    footer: {
        position: "absolute",
        bottom: 30,
        left: 40,
        right: 40,
        borderTopWidth: 1,
        borderTopColor: "#E5E7EB",
        paddingTop: 15,
        flexDirection: "row",
        justifyContent: "space-between",
        alignItems: "center",
    },
    footerText: {
        fontSize: 8,
        color: "#6B7280",
        fontFamily: "Times-Roman",
    },
    pageNumber: {
        fontSize: 8,
        color: "#6B7280",
        fontFamily: "Times-Roman",
    },
    imageContainer: {
        alignItems: "center",
        marginVertical: 10,
        padding: 5,
        borderWidth: 1,
        borderColor: "#E5E7EB",
        borderRadius: 4,
    },
    image: {
        width: "100%",
        height: 150,
        objectFit: "contain", // Respect Aspect Ratio
    }
});

export const InterviewGuidePDF = () => (
    <Document>
        <Page size="A4" style={styles.page}>
            {/* Header Page 1 */}
            <View style={styles.headerBackground}>
                <View style={{ flexDirection: "row", alignItems: "center", gap: 10 }}>
                    <Image src="/logo.png" style={{ width: 40, height: 40, marginRight: 10, objectFit: "contain" }} />
                    <View>
                        <Text style={styles.headerTitle}>US Visa Processing Center</Text>
                        <Text style={styles.headerSubtitle}>Departamento de Preparación Consular</Text>
                    </View>
                </View>
                <View style={{ alignItems: "flex-end" }}>
                    <Text style={{ color: "white", fontSize: 10, fontWeight: "bold", fontFamily: "Times-Bold" }}>GUÍA OFICIAL</Text>
                    <Text style={{ color: "white", fontSize: 8 }}>REF: PREP-B1B2-2025</Text>
                </View>
            </View>

            {/* Introduction */}
            <View style={styles.section}>
                <Text style={styles.paragraph}>
                    Estimado solicitante,
                </Text>
                <Text style={styles.paragraph}>
                    La entrevista consular es el paso final y más importante en su proceso de solicitud de visa.
                    Esta guía ha sido diseñada para maximizar sus probabilidades de éxito, basada en protocolos oficiales
                    y etiqueta diplomática. Por favor, lea este documento detenidamente y siga cada instrucción al pie de la letra.
                </Text>
            </View>

            {/* 1. Llegada al Consulado */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>1. Llegada y Procedimiento de Seguridad</Text>
                <Text style={styles.paragraph}>
                    El proceso comienza antes de entrar al edificio. La organización y la calma son fundamentales desde el primer momento.
                </Text>

                <View style={styles.imageContainer}>
                    <Image src="/interview-arrival.png" style={styles.image} />
                </View>

                <View style={styles.bulletContainer}>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>•</Text>
                        <Text style={styles.bulletText}>
                            <Text style={{ fontFamily: "Times-Bold" }}>Llegada:</Text> Llegue exactamente 30 minutos antes de su cita.
                            No se permite el ingreso antes de ese tiempo y llegar tarde puede resultar en la cancelación.
                        </Text>
                    </View>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>•</Text>
                        <Text style={styles.bulletText}>
                            <Text style={{ fontFamily: "Times-Bold" }}>Fila Exterior:</Text> Mantenga su pasaporte y hoja de confirmación en la mano.
                            El personal de seguridad verificará su cita antes de permitirle pasar al área de seguridad.
                        </Text>
                    </View>
                </View>
            </View>

            {/* 2. Código de Vestimenta */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>2. Protocolo de Vestimenta e Imagen</Text>
                <Text style={styles.paragraph}>
                    Su apariencia comunica respeto por el proceso. El objetivo es proyectar estabilidad y profesionalismo.
                </Text>

                <View style={styles.imageContainer}>
                    <Image src="/interview-dress-code.png" style={styles.image} />
                </View>

                <View style={styles.bulletContainer}>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>•</Text>
                        <Text style={styles.bulletText}>
                            <Text style={{ fontFamily: "Times-Bold" }}>Caballeros:</Text> Camisa de botones, pantalón de vestir, zapatos cerrados.
                        </Text>
                    </View>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>•</Text>
                        <Text style={styles.bulletText}>
                            <Text style={{ fontFamily: "Times-Bold" }}>Damas:</Text> Blusa formal, pantalón de vestir o falda a la rodilla.
                        </Text>
                    </View>
                </View>
            </View>

            {/* Footer Page 1 */}
            <View style={styles.footer}>
                <Text style={styles.footerText}>US Visa Processing Center • Documento Confidencial</Text>
                <Text style={styles.pageNumber}>Página 1 de 3</Text>
            </View>
        </Page>

        {/* Page 2 */}
        <Page size="A4" style={styles.page}>
            <View style={styles.headerBackground}>
                <View>
                    <Text style={styles.headerTitle}>US Visa Processing Center</Text>
                    <Text style={styles.headerSubtitle}>Departamento de Preparación Consular</Text>
                </View>
            </View>

            {/* 3. Organización de Documentos */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>3. Organización de Documentos</Text>
                <Text style={styles.paragraph}>
                    El orden demuestra preparación. Lleve sus documentos en una carpeta transparente para fácil acceso.
                </Text>

                <View style={styles.imageContainer}>
                    <Image src="/interview-documents.png" style={styles.image} />
                </View>

                <View style={styles.bulletContainer}>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>1.</Text>
                        <Text style={styles.bulletText}>Pasaporte vigente (y anteriores).</Text>
                    </View>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>2.</Text>
                        <Text style={styles.bulletText}>Hoja de Confirmación DS-160.</Text>
                    </View>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>3.</Text>
                        <Text style={styles.bulletText}>Hoja de Confirmación de Cita.</Text>
                    </View>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>4.</Text>
                        <Text style={styles.bulletText}>Evidencia Económica y Lazos (Trabajo, Banco, Propiedades).</Text>
                    </View>
                </View>
            </View>

            {/* 4. La Entrevista */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>4. Durante la Entrevista</Text>
                <Text style={styles.paragraph}>
                    La entrevista es breve y directa. Mantenga la calma y sea honesto.
                </Text>

                <View style={styles.imageContainer}>
                    <Image src="/interview-speaking.png" style={styles.image} />
                </View>

                <View style={styles.bulletContainer}>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>•</Text>
                        <Text style={styles.bulletText}>
                            <Text style={{ fontFamily: "Times-Bold" }}>Contacto Visual:</Text> Mire al oficial a los ojos.
                        </Text>
                    </View>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>•</Text>
                        <Text style={styles.bulletText}>
                            <Text style={{ fontFamily: "Times-Bold" }}>Claridad:</Text> Responda solo lo que se le pregunta. Sea conciso.
                        </Text>
                    </View>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>•</Text>
                        <Text style={styles.bulletText}>
                            <Text style={{ fontFamily: "Times-Bold" }}>Verdad:</Text> Nunca mienta. La honestidad es su mejor herramienta.
                        </Text>
                    </View>
                </View>
            </View>

            {/* Footer Page 2 */}
            <View style={styles.footer}>
                <Text style={styles.footerText}>US Visa Processing Center • Documento Confidencial</Text>
                <Text style={styles.pageNumber}>Página 2 de 3</Text>
            </View>
        </Page>

        {/* Page 3 */}
        <Page size="A4" style={styles.page}>
            <View style={styles.headerBackground}>
                <View>
                    <Text style={styles.headerTitle}>US Visa Processing Center</Text>
                    <Text style={styles.headerSubtitle}>Departamento de Preparación Consular</Text>
                </View>
            </View>

            {/* 5. Artículos Prohibidos */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>5. Artículos Prohibidos</Text>
                <View style={styles.warningBox}>
                    <Text style={styles.warningTitle}>⚠️ PROHIBIDO EL INGRESO</Text>
                    <Text style={styles.warningText}>
                        No lleve estos artículos o perderá su cita. No hay casilleros disponibles.
                    </Text>
                </View>

                <View style={styles.imageContainer}>
                    <Image src="/interview-prohibited.png" style={styles.image} />
                </View>

                <View style={styles.bulletContainer}>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>•</Text>
                        <Text style={styles.bulletText}>Celulares, Smartwatches, USBs, Audífonos.</Text>
                    </View>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>•</Text>
                        <Text style={styles.bulletText}>Mochilas grandes, maletas, bolsos voluminosos.</Text>
                    </View>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>•</Text>
                        <Text style={styles.bulletText}>Alimentos, bebidas, encendedores.</Text>
                    </View>
                </View>
            </View>

            {/* 6. Preguntas Frecuentes */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>6. Preguntas Frecuentes (Ejemplos)</Text>
                <Text style={styles.paragraph}>
                    Prepárese para responder preguntas como estas de manera natural y segura:
                </Text>
                <View style={styles.bulletContainer}>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>Q:</Text>
                        <Text style={styles.bulletText}>¿Cuál es el propósito de su viaje? (R: Turismo/Negocios/Visitar a X)</Text>
                    </View>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>Q:</Text>
                        <Text style={styles.bulletText}>¿Cuánto tiempo se quedará? (R: 2 semanas / 10 días)</Text>
                    </View>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>Q:</Text>
                        <Text style={styles.bulletText}>¿A qué se dedica? (R: Soy Ingeniero en la empresa X desde hace 5 años)</Text>
                    </View>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>Q:</Text>
                        <Text style={styles.bulletText}>¿Quién paga su viaje? (R: Yo mismo / Mi empresa / Mis padres)</Text>
                    </View>
                </View>
            </View>

            <View style={{ marginTop: 30, borderTopWidth: 1, borderTopColor: "#E5E7EB", paddingTop: 20 }}>
                <Text style={{ fontSize: 10, color: "#6B7280", textAlign: "center", fontStyle: "italic", fontFamily: "Times-Roman" }}>
                    "La preparación es la clave del éxito. Le deseamos una entrevista exitosa."
                </Text>
                <Text style={{ fontSize: 12, color: "#003366", textAlign: "center", marginTop: 10, fontWeight: "bold", fontFamily: "Times-Bold" }}>
                    US Visa Processing Center
                </Text>
            </View>

            {/* Footer Page 3 */}
            <View style={styles.footer}>
                <Text style={styles.footerText}>US Visa Processing Center • Documento Confidencial</Text>
                <Text style={styles.pageNumber}>Página 3 de 3</Text>
            </View>
        </Page>
    </Document>
);
