import { Document, Page, Text, View, StyleSheet, Image } from "@react-pdf/renderer";

const styles = StyleSheet.create({
    page: {
        flexDirection: "column",
        backgroundColor: "#FFFFFF",
        padding: 40,
        fontFamily: "Helvetica",
    },
    header: {
        marginBottom: 20,
        borderBottomWidth: 2,
        borderBottomColor: "#003366",
        paddingBottom: 10,
        flexDirection: "row",
        justifyContent: "space-between",
        alignItems: "center",
    },
    headerText: {
        flexDirection: "column",
    },
    title: {
        fontSize: 20,
        color: "#003366", // Trust Navy
        fontWeight: "bold",
        textTransform: "uppercase",
    },
    subtitle: {
        fontSize: 10,
        color: "#666666",
        marginTop: 5,
    },
    section: {
        marginBottom: 15,
        padding: 10,
        backgroundColor: "#F9FAFB",
        borderRadius: 5,
    },
    sectionTitle: {
        fontSize: 14,
        color: "#003366",
        borderBottomWidth: 1,
        borderBottomColor: "#E5E7EB",
        marginBottom: 8,
        paddingBottom: 4,
        fontWeight: "bold",
        textTransform: "uppercase",
    },
    text: {
        fontSize: 10,
        color: "#374151",
        lineHeight: 1.5,
        marginBottom: 4,
    },
    bullet: {
        fontSize: 10,
        color: "#374151",
        lineHeight: 1.5,
        marginBottom: 2,
        marginLeft: 10,
    },
    warningBox: {
        marginTop: 10,
        padding: 10,
        backgroundColor: "#FEF2F2",
        borderLeftWidth: 4,
        borderLeftColor: "#DC2626",
        borderRadius: 4,
    },
    warningTitle: {
        fontSize: 11,
        color: "#991B1B",
        fontWeight: "bold",
        marginBottom: 4,
    },
    warningText: {
        fontSize: 10,
        color: "#7F1D1D",
    },
    footer: {
        position: "absolute",
        bottom: 30,
        left: 40,
        right: 40,
        borderTopWidth: 1,
        borderTopColor: "#E5E7EB",
        paddingTop: 10,
        flexDirection: "row",
        justifyContent: "space-between",
    },
    footerText: {
        fontSize: 8,
        color: "#9CA3AF",
    },
});

export const InterviewGuidePDF = () => (
    <Document>
        <Page size="A4" style={styles.page}>
            {/* Header */}
            <View style={styles.header}>
                <View style={styles.headerText}>
                    <Text style={styles.title}>Guía de Preparación</Text>
                    <Text style={styles.subtitle}>Entrevista Consular de Visa Americana (B1/B2)</Text>
                </View>
                {/* Logo placeholder - in real app, import image */}
                <Text style={{ fontSize: 10, color: "#003366", fontWeight: "bold" }}>USAVPC</Text>
            </View>

            {/* 1. Vestimenta */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>1. Cómo Vestir (Código de Vestimenta)</Text>
                <Text style={styles.text}>La primera impresión es crucial. Vista de manera profesional y conservadora ("Business Casual").</Text>
                <Text style={styles.bullet}>• Hombres: Camisa de botones, pantalón de vestir, zapatos cerrados. Corbata opcional pero recomendada.</Text>
                <Text style={styles.bullet}>• Mujeres: Blusa formal, pantalón de vestir o falda (largo apropiado), maquillaje discreto.</Text>
                <Text style={styles.bullet}>• EVITAR: Ropa deportiva, shorts, sandalias, camisetas con mensajes políticos o gráficos llamativos, exceso de joyería.</Text>
            </View>

            {/* 2. Documentación */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>2. Qué Llevar (Documentos Esenciales)</Text>
                <Text style={styles.text}>Organice sus documentos en una carpeta transparente para fácil acceso.</Text>
                <Text style={styles.bullet}>• Pasaporte vigente (y anteriores si tienen visas).</Text>
                <Text style={styles.bullet}>• Hoja de Confirmación DS-160 (Código de Barras).</Text>
                <Text style={styles.bullet}>• Hoja de Confirmación de Cita.</Text>
                <Text style={styles.bullet}>• Fotografía reciente (5x5 cm, fondo blanco) - por si acaso.</Text>
                <Text style={styles.bullet}>• Evidencia de lazos (Carta de trabajo, estados de cuenta, títulos de propiedad, actas de nacimiento de hijos).</Text>
            </View>

            {/* 3. Prohibiciones */}
            <View style={styles.warningBox}>
                <Text style={styles.warningTitle}>⚠️ PROHIBIDO INGRESAR AL CONSULADO</Text>
                <Text style={styles.warningText}>No lleve estos artículos o perderá su cita:</Text>
                <Text style={{ ...styles.warningText, marginLeft: 10 }}>• Celulares, relojes inteligentes, audífonos, USBs.</Text>
                <Text style={{ ...styles.warningText, marginLeft: 10 }}>• Bolsos grandes, mochilas, maletas (solo carteras pequeñas o carpetas).</Text>
                <Text style={{ ...styles.warningText, marginLeft: 10 }}>• Alimentos, bebidas, encendedores, objetos punzocortantes.</Text>
            </View>

            {/* 4. La Entrevista */}
            <View style={{ ...styles.section, marginTop: 15 }}>
                <Text style={styles.sectionTitle}>3. Durante la Entrevista (Tips de Oro)</Text>
                <Text style={styles.bullet}>• PUNTUALIDAD: Llegue 15-30 minutos antes. No más (no lo dejarán entrar), no menos.</Text>
                <Text style={styles.bullet}>• VERDAD: Nunca mienta. Los oficiales tienen acceso a mucha información. Una mentira es rechazo permanente.</Text>
                <Text style={styles.bullet}>• CONSISTENCIA: Sus respuestas deben coincidir con lo que puso en su formulario DS-160.</Text>
                <Text style={styles.bullet}>• CONCISIÓN: Responda solo lo que se le pregunta. "Sí", "No", "Turismo", "2 semanas". No cuente historias si no se las piden.</Text>
                <Text style={styles.bullet}>• ACTITUD: Mantenga la calma, mire a los ojos, sea respetuoso pero seguro. Usted es un viajero legítimo.</Text>
            </View>

            {/* Footer */}
            <View style={styles.footer}>
                <Text style={styles.footerText}>© {new Date().getFullYear()} US Visa Processing Center</Text>
                <Text style={styles.footerText}>www.usvisaprocessingcenter.com</Text>
            </View>
        </Page>
    </Document>
);
