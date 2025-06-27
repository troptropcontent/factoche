import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

import translationFR from '../../public/locales/fr/translation.json';

i18n
    .use(initReactI18next)
    .init({
        fallbackLng: 'fr',
        interpolation: {
            escapeValue: false, // not needed for react as it escapes by default
        },
        resources: {
            fr: {
                translation: translationFR
            }
        }
    });

export default i18n;