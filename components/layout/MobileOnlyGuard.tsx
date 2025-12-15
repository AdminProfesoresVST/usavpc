"use client";

/**
 * [CRITICAL COMPONENT] MobileOnlyGuard
 * Date: 2025-12-15
 * Context: Enforcing mobile-first architecture by blocking desktop access.
 * Enforcement: Physical viewport check (<768px).
 * Netlify Impact: Prevents desktop users from accessing the app in production.
 * Source of Truth: Window innerWidth.
 */

import { useEffect, useState } from "react";

export function MobileOnlyGuard() {
    const [isMobile, setIsMobile] = useState(true);

    useEffect(() => {
        const checkViewport = () => {
            // 768px is the standard md breakpoint in Tailwind
            setIsMobile(window.innerWidth < 768);
        };

        // Check on mount
        checkViewport();

        // Check on resize
        window.addEventListener("resize", checkViewport);
        return () => window.removeEventListener("resize", checkViewport);
    }, []);

    if (isMobile) return null;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-gray-900 text-white p-6 text-center">
            <div className="max-w-md space-y-4">
                <h1 className="text-3xl font-bold">Modo Móvil</h1>
                <p className="text-lg text-gray-300">
                    Esta aplicación está diseñada exclusivamente para una experiencia móvil óptima.
                </p>
                <p className="text-sm text-gray-400">
                    Por favor, reduce el ancho de tu ventana o accede desde un dispositivo móvil.
                </p>
                <div className="pt-4 animate-pulse">
                    📱
                </div>
            </div>
        </div>
    );
}
