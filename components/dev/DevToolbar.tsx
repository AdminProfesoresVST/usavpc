"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { User, Shield, Briefcase, Power, Check } from "lucide-react";

type DevRole = 'client' | 'admin' | 'agent' | null;

export function DevToolbar() {
    const [isOpen, setIsOpen] = useState(false);
    const [currentRole, setCurrentRole] = useState<DevRole>(null);
    const router = useRouter();

    const isDev = process.env.NEXT_PUBLIC_DEV_MODE === 'true';

    useEffect(() => {
        // Hydration check for cookie
        const match = document.cookie.match(new RegExp('(^| )x-dev-user=([^;]+)'));
        if (match) setCurrentRole(match[2] as DevRole);
    }, []);

    if (!isDev) return null;

    const setRole = (role: DevRole) => {
        if (role) {
            document.cookie = `x-dev-user=${role}; path=/; max-age=31536000`; // 1 year
        } else {
            document.cookie = `x-dev-user=; path=/; expires=Thu, 01 Jan 1970 00:00:01 GMT`;
        }
        setCurrentRole(role);
        router.refresh(); // Refresh server components
        window.location.reload(); // Hard reload to force middleware and auth check updates
    };

    return (
        <div className={`fixed bottom-4 right-4 z-[9999] transition-all duration-300 ${isOpen ? 'bg-white shadow-2xl rounded-xl border border-gray-200 w-64' : 'w-auto'}`}>
            {!isOpen ? (
                <button
                    onClick={() => setIsOpen(true)}
                    className="bg-red-500 hover:bg-red-600 text-white p-3 rounded-full shadow-lg transition-transform hover:scale-110 flex items-center justify-center"
                    title="Open Dev Tools"
                >
                    <Shield size={24} />
                    {currentRole && <span className="absolute -top-1 -right-1 w-3 h-3 bg-green-400 rounded-full border-2 border-white"></span>}
                </button>
            ) : (
                <div className="p-4">
                    <div className="flex items-center justify-between mb-4 border-b pb-2">
                        <h3 className="font-bold text-sm text-gray-900 flex items-center gap-2">
                            <Shield size={16} className="text-red-500" />
                            DEV MODE
                        </h3>
                        <button
                            onClick={() => setIsOpen(false)}
                            className="text-gray-400 hover:text-gray-600 p-1"
                        >
                            &times;
                        </button>
                    </div>

                    <div className="space-y-2">
                        <p className="text-xs text-gray-500 font-semibold uppercase tracking-wider mb-2">Impersonate Role</p>

                        <button
                            onClick={() => setRole('client')}
                            className={`w-full flex items-center justify-between p-2 rounded-lg text-sm transition-colors ${currentRole === 'client' ? 'bg-blue-50 text-blue-700 border border-blue-200' : 'hover:bg-gray-50 text-gray-700'}`}
                        >
                            <div className="flex items-center gap-2">
                                <User size={16} />
                                <span>Applicant</span>
                            </div>
                            {currentRole === 'client' && <Check size={14} />}
                        </button>

                        <button
                            onClick={() => setRole('admin')}
                            className={`w-full flex items-center justify-between p-2 rounded-lg text-sm transition-colors ${currentRole === 'admin' ? 'bg-purple-50 text-purple-700 border border-purple-200' : 'hover:bg-gray-50 text-gray-700'}`}
                        >
                            <div className="flex items-center gap-2">
                                <Shield size={16} />
                                <span>Admin</span>
                            </div>
                            {currentRole === 'admin' && <Check size={14} />}
                        </button>

                        <button
                            onClick={() => setRole('agent')}
                            className={`w-full flex items-center justify-between p-2 rounded-lg text-sm transition-colors ${currentRole === 'agent' ? 'bg-orange-50 text-orange-700 border border-orange-200' : 'hover:bg-gray-50 text-gray-700'}`}
                        >
                            <div className="flex items-center gap-2">
                                <Briefcase size={16} />
                                <span>Agent</span>
                            </div>
                            {currentRole === 'agent' && <Check size={14} />}
                        </button>

                        <div className="border-t pt-2 mt-2">
                            <button
                                onClick={() => setRole(null)}
                                className="w-full flex items-center justify-center gap-2 p-2 rounded-lg text-sm text-red-600 hover:bg-red-50 transition-colors font-medium"
                            >
                                <Power size={16} />
                                <span>Clear Session</span>
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
