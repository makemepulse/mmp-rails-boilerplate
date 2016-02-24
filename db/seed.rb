UserAdmin.create(email: '__ADMIN__', password: "__PWD__", role: 0)
c1 = Country.create(name: 'FR', published: true)

Localization.create(name: "French", code: 'fr', published: true, is_default:true, country_id:c1.id)
