import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

i18n
    .use(initReactI18next)
    .init({
        fallbackLng: 'fr',
        interpolation: {
            escapeValue: false, // not needed for react as it escapes by default
        },
        resources: {
            fr: {
                translation: {
                    "form": {
                        "validation": {
                            "required": "Ce champ est requis",
                            "invalid": "Ce champ est invalide",
                            "min": "Ce champ doit contenir au moins {{min}} caractères",
                            "max": "Ce champ doit contenir au plus {{max}} caractères",
                            "email": "Ce champ doit être un email valide",
                        },
                        "submitError": "Une erreur est survenue lors de la soumission du formulaire"
                    },
                    "pages": {
                        "companies": {
                            "show": {
                                "title": "Mon dashboard",
                                "description": "Dashboard de la company {{companyId}}" // Fixed triple brackets to double
                            },
                            "projects": {
                                "index": {
                                    "title": "Mes projets",
                                    "add_project": "Ajouter un projet",
                                },
                                "new": {
                                    "title": "Nouveau projet",
                                },
                                "form": {
                                    "client_id": "Client",
                                    "client_id_placeholder": "Sélectionner un client",
                                    "retention_guarantee_rate": "Retenue de garantie (%)",
                                    "name": "Nom",
                                    "name_placeholder": "Nom du projet",
                                    "description": "Description",
                                    "description_placeholder": "Description du projet",
                                    "basic_info": "Informations de base", 
                                    "project_composition": "Composition du projet",
                                    "project_confirmation": "Confirmation"
                                }
                            },
                            "clients": {
                                "index": {
                                    "title": "Mes clients",
                                    "add_client": "Ajouter un client",
                                    "table": {
                                        "name": "Nom",
                                        "email": "Email",
                                        "phone": "Téléphone",
                                        "actions": "Actions",
                                        "empty_state": {
                                            "title": "Aucun client trouvé",
                                            "description": "Ajouter un client pour commencer"
                                        }
                                    },
                                    "sort_by": {
                                        "options": {
                                            "name": "Nom (A-Z)",
                                            "name_desc": "Nom (Z-A)",
                                            "email": "Email (A-Z)",
                                            "email_desc": "Email (Z-A)"
                                        },
                                        "label": "Trier par"
                                    },
                                    "search": {
                                        "placeholder": "Rechercher un client ..."
                                    }
                                },
                                "new": {
                                    "title": "Nouveau client",
                                },
                                "form": {
                                    "name": "Nom",
                                    "name_placeholder": "Nom du client",
                                    "registration_number": "Numéro Siret",
                                    "registration_number_placeholder": "Numéro Siret du client",
                                    "email": "Email",
                                    "email_placeholder": "Email du client",
                                    "phone": "Téléphone",
                                    "phone_placeholder": "Téléphone du client",
                                    "address_street": "Adresse",
                                    "address_street_placeholder": "Adresse du client",
                                    "address_city": "Ville",
                                    "address_city_placeholder": "Ville du client",
                                    "address_zipcode": "Code postal",
                                    "address_zipcode_placeholder": "Code postal du client",
                                    "submit": "Ajouter"
                                }
                            }
                        }
                    }
                }
            }
        }
    });

export default i18n;