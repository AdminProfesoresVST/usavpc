import { Document, Page, Text, View, StyleSheet, Image, Font } from "@react-pdf/renderer";

// Register fonts (using standard fonts for now to avoid loading issues in this demo)
// In production, we would register the specific GovTech fonts

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
    },
    title: {
        fontSize: 24,
        color: "#003366", // Trust Navy
        fontWeight: "bold",
        textTransform: "uppercase",
    },
    subtitle: {
        fontSize: 12,
        color: "#666666",
        marginTop: 5,
    },
    section: {
        margin: 10,
        padding: 10,
    },
    scoreContainer: {
        alignItems: "center",
        marginVertical: 20,
        padding: 20,
        backgroundColor: "#F0F2F5", // Official Grey
        borderRadius: 5,
    },
    scoreLabel: {
        fontSize: 14,
        color: "#1F2937",
        marginBottom: 5,
    },
    scoreValue: {
        fontSize: 48,
        color: "#003366",
        fontWeight: "bold",
    },
    sectionTitle: {
        fontSize: 16,
        color: "#003366",
        borderBottomWidth: 1,
        borderBottomColor: "#CCCCCC",
        marginBottom: 10,
        paddingBottom: 5,
        fontWeight: "bold",
    },
    text: {
        fontSize: 12,
        color: "#1F2937",
        lineHeight: 1.5,
        marginBottom: 5,
    },
    disclaimer: {
        position: "absolute",
        bottom: 30,
        left: 40,
        right: 40,
        fontSize: 8,
        color: "#999999",
        textAlign: "center",
        borderTopWidth: 1,
        borderTopColor: "#EEEEEE",
        paddingTop: 10,
    },
});

interface StrategyReportProps {
    data: {
        applicantName: string;
        nationality: string;
        visaScore: number;
        riskFactors: string[];
        strengths: string[];
        interviewGuide: string;
    };
}

export const StrategyReportPDF = ({ data }: StrategyReportProps) => (
    <Document>
        <Page size="A4" style={styles.page}>
            <View style={styles.header}>
                <Text style={styles.title}>Visa Strategy Review</Text>
                <Text style={styles.subtitle}>US Visa Processing Center • Confidential Report</Text>
            </View>

            <View style={styles.section}>
                <Text style={styles.text}>Applicant: {data.applicantName}</Text>
                <Text style={styles.text}>Nationality: {data.nationality}</Text>
                <Text style={styles.text}>Date: {new Date().toLocaleDateString()}</Text>
            </View>

            <View style={styles.scoreContainer}>
                <Text style={styles.scoreLabel}>Calculated VisaScore™</Text>
                <Text style={styles.scoreValue}>{data.visaScore}/100</Text>
            </View>

            <View style={styles.section}>
                <Text style={styles.sectionTitle}>Risk Profile Analysis</Text>
                {data.riskFactors.map((factor, index) => (
                    <Text key={index} style={{ ...styles.text, color: "#B71C1C" }}>• {factor}</Text>
                ))}
                {data.strengths.map((strength, index) => (
                    <Text key={index} style={{ ...styles.text, color: "#1B5E20" }}>• {strength}</Text>
                ))}
            </View>

            <View style={styles.section}>
                <Text style={styles.sectionTitle}>Interview Strategy Guide</Text>
                <Text style={styles.text}>{data.interviewGuide}</Text>
            </View>

            <View style={styles.disclaimer}>
                <Text>
                    DISCLAIMER: USVisaProcessingCenter.com is a private company aimed at facilitating the visa application process.
                    We are NOT affiliated with the United States Department of State or any government agency.
                    The purchase of our services does not guarantee visa approval.
                </Text>
            </View>
        </Page>
    </Document>
);
