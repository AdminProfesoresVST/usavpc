import { MetadataRoute } from 'next';

export default function manifest(): MetadataRoute.Manifest {
    return {
        name: 'US Visa Processing Center',
        short_name: 'USVPC',
        description: 'Secure US Visa Application Management',
        start_url: '/',
        display: 'standalone',
        background_color: '#0A1E42', // trust-navy
        theme_color: '#0A1E42', // trust-navy
        icons: [
            {
                src: '/favicon.ico',
                sizes: 'any',
                type: 'image/x-icon',
            },
        ],
    };
}
