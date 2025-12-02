export function Footer() {
    return (
        <footer className="bg-white border-t border-border py-8 text-sm text-muted-foreground">
            <div className="container mx-auto px-4 md:px-6">
                <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-4">
                    <div>
                        <h3 className="mb-4 font-serif font-bold text-primary">US Visa Processing Center</h3>
                        <p className="mb-4">
                            Professional assistance for your B1/B2 visa application. Secure, accurate, and efficient processing.
                        </p>
                    </div>
                    <div>
                        <h4 className="mb-4 font-bold text-foreground">Services</h4>
                        <ul className="space-y-2">
                            <li>Eligibility Review</li>
                            <li>Full Processing</li>
                            <li>Interview Preparation</li>
                        </ul>
                    </div>
                    <div>
                        <h4 className="mb-4 font-bold text-foreground">Legal</h4>
                        <ul className="space-y-2">
                            <li>Privacy Policy</li>
                            <li>Terms of Service</li>
                            <li>Refund Policy</li>
                        </ul>
                    </div>
                    <div>
                        <h4 className="mb-4 font-bold text-foreground">Contact</h4>
                        <ul className="space-y-2">
                            <li>support@usvisaprocessingcenter.com</li>
                            <li>1-800-VISA-HELP</li>
                        </ul>
                    </div>
                </div>
                <div className="mt-8 border-t border-border pt-8 text-center md:text-left">
                    <div className="rounded-sm bg-muted p-4 text-xs leading-relaxed text-muted-foreground border border-border">
                        <p className="font-bold mb-1">DISCLAIMER:</p>
                        <p>
                            "USVisaProcessingCenter.com is a private company aimed at facilitating the visa application process. We are NOT affiliated with the United States Department of State or any government agency. The purchase of our services does not guarantee visa approval. Users can apply directly at ceac.state.gov for a lower fee."
                        </p>
                    </div>
                    <p className="mt-4 text-center text-xs">
                        &copy; {new Date().getFullYear()} US Visa Processing Center. All rights reserved.
                    </p>
                </div>
            </div>
        </footer>
    );
}
