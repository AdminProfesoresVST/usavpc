"use client";

import { MessageSquare, User } from "lucide-react";
import { Header } from "@/components/layout/Header";

export default function SupportPage() {
    return (
        <div className="flex flex-col h-full bg-[#F0F2F5]">
            <Header title="Soporte" collapsed />
            <div className="flex-1 flex flex-col items-center justify-center text-gray-400 p-6 text-center">
                <MessageSquare className="w-12 h-12 mb-2 opacity-20" />
                <h2 className="font-bold text-gray-600">Centro de Ayuda</h2>
                <p className="text-sm">Próximamente disponible.</p>
            </div>
        </div>
    );
}
