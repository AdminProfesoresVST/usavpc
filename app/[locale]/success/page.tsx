import { CheckCircle } from "lucide-react";
import Link from "next/link";
import { Button } from "@/components/ui/button";

export default function SuccessPage() {
    return (
        <div className="container mx-auto px-4 py-16 flex flex-col items-center text-center">
            <div className="h-24 w-24 rounded-full bg-success-green/10 flex items-center justify-center mb-6">
                <CheckCircle className="h-12 w-12 text-success-green" />
            </div>
            <h1 className="text-3xl font-serif font-bold text-primary mb-4">
                Payment Successful
            </h1>
            <p className="text-muted-foreground max-w-md mb-8">
                Thank you for your payment. Your VisaScore™ Strategy Report is being generated and will be emailed to you shortly.
            </p>
            <Link href="/">
                <Button className="bg-primary text-white uppercase font-semibold">
                    Return to Home
                </Button>
            </Link>
        </div>
    );
}
