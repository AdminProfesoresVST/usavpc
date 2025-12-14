"use client";

import { User } from "lucide-react";
import { Header } from "@/components/layout/Header";

export default function ProfilePage() {
    return (
        <div className="flex flex-col h-full bg-[#F0F2F5]">
            <Header />
            <div className="flex-1 flex flex-col items-center justify-center text-gray-400 p-6 text-center">
                <User className="w-12 h-12 mb-2 opacity-20" />
                <h2 className="font-bold text-gray-600">Perfil de Usuario</h2>
                <p className="text-sm">Próximamente disponible.</p>
            </div>
        </div>
    );
}
