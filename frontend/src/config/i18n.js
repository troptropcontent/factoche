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
                        "number_in_currency": "{{amount, currency(EUR)}}",
                        "number_in_percentage": "{{amount, number(maximumFractionDigits: 2)}} %",
                        "date": "{{date, datetime}}",
                        "toast": {
                            "success": "Opération réussie",
                            "error_title": "Une erreur est survenue",
                            "error_description": "Notre équipe a été notifiée et va résoudre le problème le plus tôt possible"
                        }
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
                            "completion_snapshot": {
                                "status": {
                                    "draft": "Brouillon",
                                    "published": "Facturé",
                                    "cancelled": "Annulé"
                                },
                                "form": {
                                    "project_info": {
                                        "title": "Informations sur le projet",
                                        "name": "Nom",
                                        "version": "Version",
                                        "total_project_amount": "Montant total du projet",
                                        "previous_completion_percentage": "Avancement précédent",
                                        "remaining_amount_to_invoice": "Reliquat à facturer" 
                                    },
                                    "title": "Nouvelle situation de travaux",
                                    "details_label": "Détails",
                                    "item_total_label": "Total",
                                    "total_label": "Total de la situation de travaux: {{total}}",
                                    "previous_completion_percentage_label": "Avancement précédent",
                                    "new_completion_percentage_label": "Nouvel avancement",
                                    "submit_button_label": "Enregistrer",
                                    "success_toast_title": "Nouvelle situation de travaux enregistrée",
                                    "update_success_toast_message": "Situation de travaux modifiée"
                                },
                                "show": {
                                    "title": "Situation de travaux",
                                    "summary": {
                                        "title": "Synthese",
                                        "total": "Total",
                                        "previously_invoiced": "Précédement facturé (A)",
                                        "new_completion_snapshot": "Nouvel avancement (B)",
                                        "new_invoiced": "Nouvelle facture (B - A)",
                                        "new": {
                                            "title": "Synthese",
                                            "total": "Total (A)",
                                            "previously_invoiced": "Précédement facturé (B)",
                                            "new_completion_snapshot": "Nouvel avancement (C)",
                                            "new_invoiced": "Restant dû (A - B - C)"
                                        }
                                    },
                                    "actions": {
                                        "download_invoice_pdf": "Télécharger la facture en pdf",
                                        "invoice_pdf_unavailable": "Facture pdf en cours de génération",
                                        "download_credit_note_pdf": "Télécharger l'avoir en pdf",
                                        "credit_note_pdf_unavailable": "Avoir pdf en cours de génération",
                                        "cancel_completion_snapshot": "Annuler la situation de travaux",
                                        "cancel_completion_snapshot_success_toast_title": "Situation de travaux annulée",
                                        "publish_completion_snapshot": "Valider la situation de travaux",
                                        "publish_completion_snapshot_success_toast_title": "Situation de travaux validée",
                                        "edit": "Modifier la situation de travaux",
                                        "edit_success_toast_title": "Situation de travaux modifiée"
                                    }
                                },
                                "grouped_items_details": {
                                    "title": "Détails",
                                    "designation": "Designation",
                                    "total_amount": "Montant total",
                                    "previous_invoiced_label": "Précédement facturé (A)",
                                    "new_completion_snapshot_label": "Nouvel avancement (B)",
                                    "new_invoiced_label": "Nouvelle facture (B - A)"
                                }
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
                                            "total_amount": "Total",
                                            "invoiced_amount": "Facturé",
                                            "remaining_amount": "Restant dû"
                                        }
                                    }
                                },
                                "new": {
                                    "title": "Nouveau projet",
                                },
                                "form": {
                                    "next_button_label": "Suivant", 
                                    "previous_button_label": "Précédent",
                                    "submit_button_label": "Enregistrer",
                                    "basic_info_step": {
                                        "progress_bar_label": "Informations de base",
                                        "client_id_input_label": "Client",
                                        "client_id_input_placeholder": "Sélectionner un client",
                                        "client_id_input_description": "Vous pouvez ajouter un client dans votre section <a >clients</a>",
                                        "retention_guarantee_rate_input_label": "Retenue de garantie (%)",
                                        "retention_guarantee_rate_input_description": "Retenue de garantie (%) qui sera appliquée sur les factures de situation.",
                                        "name_input_label": "Nom",
                                        "name_input_placeholder": "Nom de la commande",
                                        "name_input_description": "Nom que vous souhaitez donner à la commande qui sera affiché dans l'application et sur les factures.",
                                        "description_input_label": "Description",
                                        "description_input_placeholder": "Description de la commande",
                                        "description_input_description": "Description de la commande qui sera affiché dans l'application, optionnel.",
                                    },
                                    "composition_step": {
                                        "progress_bar_label": "Composition de la commande",
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
                                        "import_csv": "Importer un fichier csv",
                                        "import_csv_modal": {
                                            "title": "Importer un fichier csv",
                                            "description": "Importer un fichier csv pour commencer",
                                            "errors": {
                                                "parsing_error": "Une erreur est survenue lors de l'analyse du fichier csv",
                                                "csv_file_required": "Seul les fichiers csv sont supportés",
                                                "title": "Une erreur est survenue",
                                                "file_required": "Veuillez d'abord sélectionner un fichier",
                                                "no_headers_detected": "Aucun en-tête de colonne détecté",
                                                "missing_fields": "Colonnes manquantes: {{missingFields}}",
                                                "no_items_detected": "Aucun élément détecté",
                                                "missing_data": "La ligne {{line}} ne possède pas de donnée dans la colonne {{column}}.",
                                                "invalid_number_data": "La ligne {{line}} possède une valeur invalide dans la colonne {{column}}. La valeur doit être un nombre.",
                                                "invalid_percentage_data": "La ligne {{line}} possède une valeur invalide dans la colonne {{column}}. La valeur doit être un nombre entre 0 et 100.",
                                            },
                                            "debug_info": {
                                                "title": "Informations de débogage",
                                                "detected_fields": "Colonnes détectées: {{headers}}",
                                                "detected_groups": "Groupes détectés: {{count}} ",
                                                "detected_items": "Éléments détectés: {{count}} ",
                                            },
                                            "tabs": {
                                                "upload": {
                                                    "label": "Import",
                                                    "drop_zone_title": "Importer un fichier csv",
                                                    "drop_zone_label": "Glisser et déposer un fichier csv ici ou cliquer pour télécharger",
                                                    "drop_zone_upload_button_label": "Télécharger un fichier csv",
                                                    "drop_zone_download_template_button_label": "Télécharger un modèle",
                                                    "expected_columns": {
                                                        "label": "Colonnes attendues",
                                                        "description": "Colonnes attendues dans le fichier csv",
                                                        "name": "Désignation",
                                                        "group": "Groupe",
                                                        "quantity": "Quantité",
                                                        "unit": "Unité",
                                                        "unit_price_amount": "Prix unitaire",
                                                        "tax_rate": "Taux de TVA"
                                                    },
                                                    "template": {
                                                        "line1": {
                                                            "group": "Groupe 1",
                                                            "name": "Élément 1",
                                                            "quantity": "1",
                                                            "unit": "Unité",
                                                            "unit_price_amount": "100",
                                                            "tax_rate": "20"
                                                        },
                                                        "line2": {
                                                            "group": "Groupe 1",
                                                            "name": "Élément 2",
                                                            "quantity": "1",
                                                            "unit": "Unité",
                                                            "unit_price_amount": "100",
                                                            "tax_rate": "20"
                                                        }
                                                    }
                                                },
                                                "mapping": {
                                                    "label": "Mapping",
                                                    "title": "Mapping des colonnes",
                                                    "description": "Associer les colonnes du fichier csv aux colonnes attendues",
                                                    "placeholder": "Sélectionner une colonne"
                                                },
                                                "preview": {
                                                    "label": "Prévisualisation",
                                                    "title": "Les éléments suivants seront importés",
                                                    "description": "Voir les éléments qui seront importés",
                                                    "only_first_five_rows": "Seules les 5 premières lignes sont affichées",
                                                    "total_excl_vat_label": "Total HT",
                                                    "number_of_element_imported_one": "{{count}} élément sera importé",
                                                    "number_of_element_imported_other": "{{count}} éléments seront importés"
                                                },
                                                "actions": {
                                                    "continue_button_label": "Continuer",
                                                    "back_button_label": "Retour",
                                                    "import_button_label": "Importer les éléments",
                                                    "importing_button_label": "Importation en cours...",
                                                    "processing_button_label": "Analyse en cours...",
                                                }
                                            }
                                        },
                                        "item_group_name_input_label": "Nom du groupe d'éléments",
                                        "item_group_name_input_placeholder": "Nom du groupe d'éléments",
                                        "item_group_name_input_description": "Nom du groupe d'éléments, par exemple : \"Bâtiment\", \"Mécanique\", \"Électricité\", etc.",
                                        "item_group_add_item_button_label": "Ajouter un élément au groupe",
                                        "no_items_error": "Vous devez ajouter au moins un élément au projet",
                                        "no_items_in_group_error": "Vous devez ajouter au moins un élément au groupe",
                                        "items_total_label": "Total des différents éléments: {{total}}",
                                        "tax_rate_input_label": "Taux de TVA",
                                        "tax_rate_input_description": "Taux de TVA appliqué à l'élément",
                                        "empty_state": {
                                            "title": "Aucun élément trouvé",
                                            "description": "Ajouter un premier groupe d'éléments ou importer un fichier csv pour commencer",
                                            "action_label": "Ajouter un groupe d'éléments"
                                        }
                                    },
                                    "confirmation_step": {
                                        "progress_bar_label": "Confirmation",
                                        "total_project_amount_label": "Total de la commande: {{total}}",
                                        "group_total_label": "Total du groupe: {{total}}",
                                        "toast": {
                                            "success_toast_title": "Devis enregistré",
                                            "success_toast_description": "Le devis a été enregistré avec succès",
                                            "error_toast_title": "Une erreur est survenue",
                                            "error_toast_description": "Une erreur est survenue lors de l'enregistrement du devis, notre équipe a été notifiée et va résoudre le problème le plus tôt possible"
                                        },
                                        "item": "Element",
                                    },
                                    "project_composition": "Composition de la commande",
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
                                    "title": "Fiche synthétique du projet",
                                    "project_versions": "Versions du project",
                                    "version_label": "Version n°{{number}} ({{createdAt, datetime}})",
                                    "client_info": {
                                        "title": "Information client",
                                        "name": "<strong>Nom :</strong> {{name}}",
                                        "phone": "<strong>Téléphone :</strong> {{phone}}",
                                        "email": "<strong>Email :</strong> {{email}}"
                                    },
                                    "project_summary": {
                                        "title": "Information sur la commande",
                                        "name": "<strong>Nom :</strong> {{name}}",
                                        "description": "<strong>Description :</strong> {{description}}",
                                        "version_label": "<strong>Version :</strong> N°{{number}} du {{createdAt, datetime}}",
                                    },
                                    "project_composition": {
                                        "title": "Composition de la commande",
                                        "project_total": "Total:"
                                    },
                                    "new_completion_snapshot": "Nouvelle situation de travaux",
                                    "completion_snapshot_invoices_summary": {
                                        "title": "Factures",
                                        "empty_state": {
                                            "title": "Aucune facture trouvée",
                                            "description": "Créer une facture pour commencer à facturer",
                                            "action_label": "Créer une facture"
                                        },
                                        "columns": {
                                            "number": "Numéro",
                                            "number_when_empty": "N/A",
                                            "date": "Date",
                                            "status": "Status",
                                            "amount": "Montant",
                                        },
                                        "new_completion_snapshot_invoice_button": {
                                            "disabled_hint": "Vous ne pouvez avoir qu'une seule facture en cours de rédaction"
                                        }
                                    }
                                },
                                "invoices": {
                                    "completion_snapshot": {
                                        "show": {
                                            "status": {
                                                "draft": "Brouillon",
                                                "posted": "Postée",
                                                "cancelled": "Annulée",
                                                "voided": "Supprimée"
                                            },
                                            "title_published": "Facture de situation N°{{number}}",
                                            "title_unpublished": "Facture PROFORMA de situation N°{{number}}",
                                            "content": {
                                                "title": "Détails de la facture",
                                                "withGroups": {
                                                    "columns": {
                                                        "name": "Nom",
                                                        "total": "Total",
                                                        "previously_invoiced": "Déja facturé",
                                                        "new_snapshot": "Nouvelle situation",
                                                        "new_invoice": "Nouvelle facture",
                                                    }
                                                }
                                            },
                                            "actions": {
                                                "edit": "Modifier la facture proforma",
                                                "post": "Valider la facture proforma",
                                                "post_success_toast_title": "Facture proforma validée",
                                                "post_success_toast_description": "La facture proforma a été validée et est désormais une facture",
                                                "void": "Supprimer la facture proforma",
                                                "void_success_toast_title": "Facture proforma supprimée",
                                                "void_success_toast_description": "La facture proforma a bien été supprimée",
                                                "download_invoice_pdf": "Télécharger la facture",
                                                "invoice_pdf_unavailable": "Facture en cours de génération",
                                                "download_credit_note_pdf": "Télécharger l'avoir",
                                                "credit_note_pdf_unavailable": "Avoir en cours de génération",
                                                "download_proforma_pdf": "Télécharger la facture proforma",
                                                "proforma_pdf_unavailable": "Facture proforma en cours de génération",
                                                "cancel": "Annuler la facture",
                                                "cancel_success_toast_title": "Facture annulée",
                                                "cancel_success_toast_description": "La facture a bien été annulée",
                                            }
                                        },
                                        "new": {
                                            "title": "Nouvelle facture d'avancement",
                                        },
                                        "form": {
                                            "project_summary": {
                                                "title": "Information projet",
                                                "columns": {
                                                    "name": "Nom",
                                                    "version": "Version",
                                                    "total": "Montant total",
                                                    "previously_invoiced": "Précédement facturé",
                                                    "new_invoice_amount": "Nouvelle facture",
                                                    "remaining_amount": "Restant dû",
                                                }
                                            },
                                            "columns": {
                                                "designation": "Designation",
                                                "total": "Total",
                                                "previously_invoiced_amount": "Précédement facturé",
                                                "new_completion_percentage": "Nouvel avancement",
                                                "new_invoice_amount": "Nouvelle facture",
                                            },
                                            "toast": {
                                                "create_success_toast_title": "Nouvelle facture d'avancement enregistrée"
                                            },
                                            "total_info": "Total de la facture: <strong>{{total}}<strong>"
                                        }
                                    },
                                    "index": {
                                        "title": "Mes factures",
                                        "tabs": {
                                            "table": {
                                                "columns": {
                                                    "number": "Numéro",
                                                    "client": "Client",
                                                    "order": "Commande",
                                                    "invoice_number": "Facture originale",
                                                    "date": "Date",
                                                    "status": "Status",
                                                    "amount": "Montant",
                                                    "actions": "Actions"
                                                }
                                            },
                                            "invoices": {
                                                "label": "Factures",
                                                "title": "Factures",
                                                "description": "Retrouvez toutes vos factures ci-dessous",
                                                "empty_state": {
                                                    "title": "Aucune facture trouvée",
                                                }
                                            },
                                            "creditNotes": {
                                                "label": "Avoirs",
                                                "title": "Avoirs",
                                                "description": "Retrouvez tous vos avoirs ci-dessous",
                                                "empty_state": {
                                                    "title": "Aucun avoir trouvé",
                                                }
                                            },
                                            "proforma": {
                                                "label": "Proforma",
                                                "title": "Proforma",
                                                "description": "Retrouvez toutes vos factures proforma ci-dessous",
                                                "empty_state": {
                                                    "title": "Aucune facture proforma trouvée",
                                                }
                                            }
                                        }
                                    }
                                }
                            },
                            "quotes": {
                                "show": {
                                    "title": "Devis N°{{number}}",
                                    "actions": {
                                        "update_quote": "Modifier le devis",
                                        "download_quote_pdf": "Télécharger le devis",
                                        "quote_pdf_unavailable": "Devis en cours de génération",
                                        "update_quote": "Modifier le devis",
                                        "convert_to_order": "Convertir en commande",
                                        "convert_to_order_success_toast_title": "Devis converti en commande",
                                        "convert_to_order_success_toast_description": "Le devis a bien été converti en commande",
                                        "convert_to_order_error_toast_title": "Une erreur est survenue",
                                        "convert_to_order_error_toast_description": "Une erreur est survenue lors de la conversion du devis en commande, notre équipe a été notifiée et va résoudre le problème le plus tôt possible",
                                        "go_order": "Voir la commande liée"
                                    }
                                },
                                "new": {
                                    "title": "Nouveau devis",
                                },
                                "update": {
                                    "title": "Modifier le devis N°{{number}}",
                                },
                                "status": {
                                    "draft": "Brouillon",
                                    "posted": "Validé",
                                },
                                "index": {
                                    "title": "Mes devis",
                                    "add_quote": "Créer un devis",
                                    "table": {
                                        "columns": {
                                            "number": "Numéro",
                                            "name": "Nom",
                                            "client": "Client",
                                            "amount": "Montant",
                                            "status": "Status",
                                        }
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
                                    "vat_number": "Numéro de TVA",
                                    "vat_number_placeholder": "Numéro de TVA du client",
                                    "submit": "Ajouter"
                                }
                            },
                            "settings": {
                                "title": "Paramètres",
                                "forms": {
                                    "shared": {
                                        "submit": "Enregistrer",
                                        "success_toast_title": "Paramètres enregistrés",
                                        "success_toast_description": "Les paramètres ont été enregistrés avec succès",
                                        "error_toast_title": "Une erreur est survenue",
                                        "error_toast_description": "Une erreur est survenue lors de l'enregistrement des paramètres, notre équipe a été notifiée et va résoudre le problème le plus tôt possible"
                                    },
                                    "general": {
                                        "title": "Paramètres généraux",
                                        "description": "Configurez les paramètres généraux de votre entreprise",
                                        "fields": {
                                            "name": "Nom",
                                            "name_placeholder": "Nom de l'entreprise",
                                            "registration_number": "Numéro d'enregistrement",
                                            "registration_number_placeholder": "Numéro d'enregistrement de l'entreprise",
                                            "email": "Email",
                                            "email_placeholder": "Email de l'entreprise",
                                            "phone": "Téléphone",
                                            "phone_placeholder": "Téléphone de l'entreprise",
                                            "address_street": "Adresse",
                                            "address_street_placeholder": "Adresse de l'entreprise",
                                            "address_city": "Ville",
                                            "address_city_placeholder": "Ville de l'entreprise",
                                            "address_zipcode": "Code postal",
                                            "address_zipcode_placeholder": "Code postal de l'entreprise",
                                            "vat_number": "Numéro de TVA",
                                            "vat_number_placeholder": "Numéro de TVA de l'entreprise",
                                            "capital_amount": "Montant du capital",
                                            "capital_amount_placeholder": "Montant du capital de l'entreprise",
                                            "legal_form": "Forme juridique",
                                            "legal_form_placeholder": "Sélectionnez la forme juridique",
                                            "rcs_city": "Ville RCS",
                                            "rcs_city_placeholder": "Ville d'enregistrement RCS",
                                            "rcs_number": "Numéro RCS",
                                            "rcs_number_placeholder": "Numéro RCS de l'entreprise"
                                        }
                                    },
                                    "billing": {
                                        "title": "Paramètres de facturation",
                                        "description": "Configurez les paramètres de facturation de votre entreprise",
                                        "fields": {
                                            "payment_term_days": "Délai de paiement (jours)",
                                            "payment_term_accepted_methods": "Méthodes de paiement acceptées",
                                            "default_vat_rate": "Taux de TVA par défaut",
                                            "general_terms_and_condition": "Conditions générales",
                                        }
                                    },
                                }
                            }
                        }
                    }
                }
            }
        }
    });

export default i18n;