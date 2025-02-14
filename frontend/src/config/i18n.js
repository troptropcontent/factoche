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
                            "too_small": "Ce champ est requis",
                            "unexpected_error": "Ce champ est invalide"
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
                                    "table": {
                                        "columns": {
                                            "name": "Nom",
                                            "status": "Status",
                                            "client": "Client",
                                            "total_amount": "Montant total",
                                            "progress": "Avancement",
                                            "last_invoice_date": "Dérnière facture"
                                        }
                                    }
                                },
                                "new": {
                                    "title": "Nouveau projet",
                                },
                                "form": {
                                    "next_button_label": "Suivant", 
                                    "previous_button_label": "Précédent",
                                    "submit_button_label": "Créer le projet",
                                    "basic_info_step": {
                                        "progress_bar_label": "Informations de base",
                                        "client_id_input_label": "Client",
                                        "client_id_input_placeholder": "Sélectionner un client",
                                        "client_id_input_description": "Vous pouvez ajouter un client dans votre section <a >clients</a>",
                                        "retention_guarantee_rate_input_label": "Retenue de garantie (%)",
                                        "retention_guarantee_rate_input_description": "Retenue de garantie (%) qui sera appliquée sur le projet.",
                                        "name_input_label": "Nom",
                                        "name_input_placeholder": "Nom du projet",
                                        "name_input_description": "Nom que vous souhaitez donner à votre projet qui sera affiché dans l'application.",
                                        "description_input_label": "Description",
                                        "description_input_placeholder": "Description du projet",
                                        "description_input_description": "Description du projet qui sera affiché dans l'application, optionnel.",
                                    },
                                    "composition_step": {
                                        "progress_bar_label": "Composition du projet",
                                        "item_name_input_label": "Nom",
                                        "item_name_input_placeholder": "Nom de l'élément",
                                        "item_name_input_description": "Nom de l'élément, ce nom sera repris dans les factures.",
                                        "item_quantity_input_label": "Quantité",
                                        "item_quantity_input_placeholder": "Quantité de l'élément",
                                        "item_quantity_input_description": "Nombre d'unités de l'élément",
                                        "item_unit_input_label": "Unité",
                                        "item_unit_input_placeholder": "Unité de l'élément",
                                        "item_unit_input_description": "Pièce, mètre, heure, etc.",
                                        "item_unit_price_input_label": "Prix unitaire",
                                        "item_unit_price_input_placeholder": "Prix unitaire de l'élément",
                                        "item_unit_price_input_description": "Prix unitaire de l'élément",
                                        "item_total_label": "Total",
                                        "item_total_description": "Total de la ligne",
                                        "add_item_group": "Ajouter un groupe d'éléments",
                                        "item_group_name_input_label": "Nom du groupe d'éléments",
                                        "item_group_name_input_placeholder": "Nom du groupe d'éléments",
                                        "item_group_name_input_description": "Nom du groupe d'éléments, par exemple : \"Bâtiment\", \"Mécanique\", \"Électricité\", etc.",
                                        "item_group_add_item_button_label": "Ajouter un élément au groupe",
                                        "no_items_error": "Vous devez ajouter au moins un élément au projet",
                                        "no_items_in_group_error": "Vous devez ajouter au moins un élément au groupe",
                                        "items_total_label": "Total des différents éléments: {{total}}",
                                        "empty_state": {
                                            "title": "Aucun élément trouvé",
                                            "description": "Ajouter un premier groupe d'éléments pour commencer",
                                            "action_label": "Ajouter un groupe d'éléments"
                                        }
                                    },
                                    "confirmation_step": {
                                        "progress_bar_label": "Confirmation",
                                        "total_project_amount_label": "Total du projet: {{total}}",
                                        "group_total_label": "Total du groupe: {{total}}",
                                        "item": "Element",
                                    },
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
                                },
                                "show": {
                                    "project_versions": "Versions du project",
                                    "version_label": "Version n°{{number}} ({{createdAt, datetime}})",
                                    "client_info": {
                                        "title": "Information client"
                                    },
                                    "project_composition": {
                                        "title": "Composition du project",
                                        "project_total": "Total:"
                                    }
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