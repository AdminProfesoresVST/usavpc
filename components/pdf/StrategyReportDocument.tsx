import { Document, Page, Text, View, StyleSheet, Image } from '@react-pdf/renderer';
import { DS160Payload } from '@/types/ds160';

const styles = StyleSheet.create({
    page: {
        flexDirection: 'column',
        backgroundColor: '#FFFFFF',
        padding: 40,
        fontFamily: 'Helvetica',
    },
    header: {
        marginBottom: 30,
        borderBottom: 2,
        borderBottomColor: '#1a365d',
        paddingBottom: 10,
    },
    title: {
        fontSize: 28,
        fontWeight: 'bold',
        color: '#1a365d',
        marginBottom: 5,
    },
    subtitle: {
        fontSize: 14,
        color: '#666',
    },
    scoreSection: {
        marginBottom: 30,
        padding: 20,
        backgroundColor: '#f8fafc',
        borderRadius: 5,
        border: 1,
        borderColor: '#e2e8f0',
    },
    scoreTitle: {
        fontSize: 18,
        fontWeight: 'bold',
        marginBottom: 10,
        color: '#2d3748',
    },
    scoreValue: {
        fontSize: 36,
        fontWeight: 'bold',
        color: '#2b6cb0',
        textAlign: 'center',
        marginVertical: 10,
    },
    section: {
        marginBottom: 20,
    },
    sectionTitle: {
        fontSize: 16,
        fontWeight: 'bold',
        color: '#2d3748',
        marginBottom: 10,
        borderBottom: 1,
        borderBottomColor: '#e2e8f0',
        paddingBottom: 5,
    },
    text: {
        fontSize: 11,
        lineHeight: 1.5,
        color: '#4a5568',
        marginBottom: 5,
    },
    warningBox: {
        backgroundColor: '#fff5f5',
        borderLeft: 4,
        borderLeftColor: '#f56565',
        padding: 10,
        marginBottom: 10,
    },
    warningText: {
        fontSize: 11,
        color: '#c53030',
    },
    footer: {
        position: 'absolute',
        bottom: 30,
        left: 40,
        right: 40,
        textAlign: 'center',
        fontSize: 8,
        color: '#a0aec0',
        borderTop: 1,
        borderTopColor: '#e2e8f0',
        paddingTop: 10,
    }
});

interface StrategyReportProps {
    data: any; // Application data with risk_assessment and interview_guide
}

export const StrategyReportDocument = ({ data }: StrategyReportProps) => {
    const risk = data.risk_assessment || {};
    const guide = data.interview_guide || "Guide generation pending...";

    // Parse guide if it's markdown (simple cleanup for PDF)
    // In a real app, we'd use a markdown-to-pdf parser, but here we'll just dump text
    const cleanGuide = guide.replace(/[*#]/g, '');

    return (
        <Document>
            <Page size="A4" style={styles.page}>
                <View style={styles.header}>
                    <Text style={styles.title}>VisaScore™ Strategy Audit</Text>
                    <Text style={styles.subtitle}>Confidential Diagnostic Report</Text>
                </View>

                {/* VisaScore Section */}
                <View style={styles.scoreSection}>
                    <Text style={styles.scoreTitle}>Risk Assessment</Text>
                    <Text style={styles.scoreValue}>
                        {risk.score ? `${risk.score}/100` : 'Pending'}
                    </Text>
                    <Text style={{ textAlign: 'center', fontSize: 12, color: '#718096' }}>
                        Approval Probability Score
                    </Text>
                </View>

                {/* Red Flags Section */}
                <View style={styles.section}>
                    <Text style={styles.sectionTitle}>Identified Risk Factors (Red Flags)</Text>
                    {risk.flags && risk.flags.length > 0 ? (
                        risk.flags.map((flag: string, i: number) => (
                            <View key={i} style={styles.warningBox}>
                                <Text style={styles.warningText}>• {flag}</Text>
                            </View>
                        ))
                    ) : (
                        <Text style={styles.text}>No critical red flags detected based on provided data.</Text>
                    )}
                </View>

                {/* Strategy Guide Section */}
                <View style={styles.section}>
                    <Text style={styles.sectionTitle}>Corrective Action Plan & Interview Strategy</Text>
                    <Text style={styles.text}>{cleanGuide}</Text>
                </View>

                <View style={styles.footer}>
                    <Text>US Visa Processing Center • Strategy Audit Service</Text>
                    <Text>This is a diagnostic tool, not legal advice. Does not guarantee visa issuance.</Text>
                </View>
            </Page>
        </Document>
    );
};
