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
                    "common": {
                        "total": "Total",
                        "number_in_currency": "{{amount, currency(EUR)}}"
                    },
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
                                    "project_confirmation": "Confirmation",
                                    "add_item": "Ajouter un élément",
                                    "add_item_group": "Ajouter un groupe d'éléments",
                                    "item_group_name_input_label": "Nom du groupe d'éléments",
                                    "item_group_name_input_placeholder": "Nom du groupe d'éléments",
                                    "item_group_add_item_button_label": "Ajouter un élément au groupe",
                                    "item_name_input_label": "Nom de l'élément",
                                    "item_name_input_placeholder": "Nom de l'élément",
                                    "item_quantity_input_label": "Quantité",
                                    "item_unit_input_label": "Unité",
                                    "item_unit_input_placeholder": "Unité de l'élément",
                                    "item_unit_price_input_label": "Prix unitaire",
                                    "item_total_label": "Total",
                                    "composition_empty_state_title": "Aucun élément trouvé",
                                    "composition_empty_state_description": "Ajouter un élément ou un groupe d'éléments pour commencer"
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