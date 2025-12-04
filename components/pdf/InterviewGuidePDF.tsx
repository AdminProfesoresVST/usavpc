import { Document, Page, Text, View, StyleSheet, Image, Font } from "@react-pdf/renderer";

// Define styles for a professional letterhead look
const styles = StyleSheet.create({
    page: {
        flexDirection: "column",
        backgroundColor: "#FFFFFF",
        paddingTop: 0, // Header will take top space
        paddingBottom: 40,
        paddingHorizontal: 40,
        fontFamily: "Helvetica",
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
    },
    headerSubtitle: {
        color: "#E5E7EB",
        fontSize: 10,
        marginTop: 4,
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
    },
    paragraph: {
        fontSize: 11,
        color: "#374151",
        lineHeight: 1.6,
        marginBottom: 8,
        textAlign: "justify",
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
        color: "#003366",
    },
    bulletText: {
        fontSize: 11,
        color: "#374151",
        lineHeight: 1.6,
        flex: 1,
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
    },
    warningText: {
        fontSize: 10,
        color: "#7F1D1D",
        lineHeight: 1.5,
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
    },
    pageNumber: {
        fontSize: 8,
        color: "#6B7280",
    },
});

export const InterviewGuidePDF = () => (
    <Document>
        <Page size="A4" style={styles.page}>
            {/* Professional Header (Letterhead) */}
            <View style={styles.headerBackground}>
                <View>
                    <Text style={styles.headerTitle}>US Visa Processing Center</Text>
                    <Text style={styles.headerSubtitle}>Departamento de Preparación Consular</Text>
                </View>
                <View style={{ alignItems: "flex-end" }}>
                    <Text style={{ color: "white", fontSize: 10, fontWeight: "bold" }}>GUÍA OFICIAL</Text>
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

            {/* 1. Código de Vestimenta */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>1. Protocolo de Vestimenta e Imagen</Text>
                <Text style={styles.paragraph}>
                    Su apariencia comunica respeto por el proceso y seriedad en sus intenciones. El objetivo es proyectar
                    estabilidad, profesionalismo y confianza. No es necesario vestir de gala, pero sí de manera formal ("Business Casual").
                </Text>

                <View style={styles.bulletContainer}>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>•</Text>
                        <Text style={styles.bulletText}>
                            <Text style={{ fontWeight: "bold" }}>Caballeros:</Text> Se recomienda camisa de botones (planchada),
                            pantalón de vestir (no jeans) y zapatos cerrados y limpios. El uso de saco o corbata es opcional pero
                            altamente recomendado si su profesión lo amerita.
                        </Text>
                    </View>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>•</Text>
                        <Text style={styles.bulletText}>
                            <Text style={{ fontWeight: "bold" }}>Damas:</Text> Se sugiere blusa formal, pantalón de vestir o falda
                            a la rodilla. Maquillaje discreto y peinado ordenado. Evite escotes pronunciados o ropa muy ajustada.
                        </Text>
                    </View>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>•</Text>
                        <Text style={styles.bulletText}>
                            <Text style={{ fontWeight: "bold" }}>Lo que debe evitar:</Text> Ropa deportiva, camisetas con logotipos
                            grandes o mensajes políticos, sandalias, gorras, lentes oscuros y exceso de joyería llamativa.
                        </Text>
                    </View>
                </View>
            </View>

            {/* 2. Documentación */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>2. Organización de Documentos</Text>
                <Text style={styles.paragraph}>
                    El orden demuestra preparación. Lleve sus documentos en una carpeta transparente o un folder clasificatorio,
                    ordenados de la siguiente manera para entregarlos rápidamente si el oficial los solicita:
                </Text>

                <View style={styles.bulletContainer}>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>1.</Text>
                        <Text style={styles.bulletText}>Pasaporte vigente (y pasaportes anteriores si contienen visas americanas).</Text>
                    </View>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>2.</Text>
                        <Text style={styles.bulletText}>Hoja de Confirmación del Formulario DS-160 (la hoja con el código de barras).</Text>
                    </View>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>3.</Text>
                        <Text style={styles.bulletText}>Hoja de Confirmación de Cita (impresa).</Text>
                    </View>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>4.</Text>
                        <Text style={styles.bulletText}>Evidencia de Solvencia Económica: Estados de cuenta bancarios (últimos 3 meses), cartas de trabajo, declaraciones de impuestos.</Text>
                    </View>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>5.</Text>
                        <Text style={styles.bulletText}>Lazos con su País: Actas de nacimiento de hijos, actas de matrimonio, títulos de propiedad de vehículos o bienes raíces.</Text>
                    </View>
                </View>
            </View>

            {/* Footer Page 1 */}
            <View style={styles.footer}>
                <Text style={styles.footerText}>US Visa Processing Center • Documento Confidencial</Text>
                <Text style={styles.pageNumber}>Página 1 de 2</Text>
            </View>
        </Page>

        {/* Page 2 */}
        <Page size="A4" style={styles.page}>
            {/* Header Page 2 */}
            <View style={styles.headerBackground}>
                <View>
                    <Text style={styles.headerTitle}>US Visa Processing Center</Text>
                    <Text style={styles.headerSubtitle}>Departamento de Preparación Consular</Text>
                </View>
            </View>

            {/* 3. Comportamiento y Etiqueta */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>3. Comportamiento Durante la Entrevista</Text>
                <Text style={styles.paragraph}>
                    La entrevista suele durar menos de 3 minutos. Cada segundo cuenta. Su lenguaje corporal habla tan fuerte como sus palabras.
                </Text>

                <View style={styles.bulletContainer}>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>•</Text>
                        <Text style={styles.bulletText}>
                            <Text style={{ fontWeight: "bold" }}>Puntualidad:</Text> Llegue al consulado 30 minutos antes de su hora programada.
                            Llegar demasiado temprano puede causar aglomeraciones, pero llegar tarde resultará en la cancelación de su cita.
                        </Text>
                    </View>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>•</Text>
                        <Text style={styles.bulletText}>
                            <Text style={{ fontWeight: "bold" }}>Contacto Visual:</Text> Mire al oficial a los ojos cuando hable.
                            Mirar al suelo o a los lados puede interpretarse como inseguridad o falta de honestidad.
                        </Text>
                    </View>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>•</Text>
                        <Text style={styles.bulletText}>
                            <Text style={{ fontWeight: "bold" }}>Claridad y Concisión:</Text> Responda exactamente lo que se le pregunta.
                            Si le preguntan "¿A dónde va?", responda "A Orlando, Florida". No empiece a contar toda la historia de por qué eligió ese destino a menos que se lo pidan.
                        </Text>
                    </View>
                    <View style={styles.bulletItem}>
                        <Text style={styles.bulletPoint}>•</Text>
                        <Text style={styles.bulletText}>
                            <Text style={{ fontWeight: "bold" }}>Honestidad Absoluta:</Text> Nunca mienta. Los oficiales consulares son expertos
                            en detectar engaños y tienen acceso a bases de datos extensas. Una mentira pequeña puede resultar en una prohibición permanente.
                        </Text>
                    </View>
                </View>
            </View>

            {/* 4. Prohibiciones */}
            <View style={styles.warningBox}>
                <Text style={styles.warningTitle}>⚠️ IMPORTANTE: ARTÍCULOS PROHIBIDOS</Text>
                <Text style={styles.warningText}>
                    Por razones de seguridad nacional, está estrictamente prohibido ingresar al consulado con los siguientes artículos.
                    No hay casilleros disponibles para guardarlos, por lo que si los lleva, perderá su cita.
                </Text>
                <View style={{ marginTop: 8, marginLeft: 10 }}>
                    <Text style={styles.warningText}>• Teléfonos celulares, relojes inteligentes (Smartwatches), audífonos, USBs o cualquier dispositivo electrónico.</Text>
                    <Text style={styles.warningText}>• Bolsos grandes, mochilas, maletas o pañaleras grandes (solo se permiten carteras pequeñas o carpetas de documentos).</Text>
                    <Text style={styles.warningText}>• Alimentos, bebidas, cigarrillos, encendedores o fósforos.</Text>
                    <Text style={styles.warningText}>• Objetos punzocortantes, armas de cualquier tipo o materiales explosivos.</Text>
                </View>
            </View>

            <View style={{ marginTop: 30, borderTopWidth: 1, borderTopColor: "#E5E7EB", paddingTop: 20 }}>
                <Text style={{ fontSize: 10, color: "#6B7280", textAlign: "center", fontStyle: "italic" }}>
                    "La preparación es la clave del éxito. Le deseamos una entrevista exitosa."
                </Text>
                <Text style={{ fontSize: 12, color: "#003366", textAlign: "center", marginTop: 10, fontWeight: "bold" }}>
                    US Visa Processing Center
                </Text>
            </View>

            {/* Footer Page 2 */}
            <View style={styles.footer}>
                <Text style={styles.footerText}>US Visa Processing Center • Documento Confidencial</Text>
                <Text style={styles.pageNumber}>Página 2 de 2</Text>
            </View>
        </Page>
    </Document>
);
