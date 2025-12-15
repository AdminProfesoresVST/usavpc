import { DetailedServicesList } from "@/components/services/DetailedServicesList";

export const metadata = {
    title: "Select Service | US Visa Processing Center",
    description: "Choose the right visa application service for your needs.",
};

export default function ServicesPage() {
    return (
        <div className="w-full h-full p-4 md:p-6 max-w-2xl mx-auto">
            <DetailedServicesList />
        </div>
    );
}
