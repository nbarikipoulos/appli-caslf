## Présentation

Application de création/réservation de créneaux horaires pour club sportif:
- calendrier:
    -  des séances planifiées (aka habituelles),
    - ou non *i.e.* ouverture à façon par les membres disposant d'un accès,
    - en corollaire, informe automatiquement les autres membres du club des ouvertures,
    - possibilité de demander un créneau pour les non détenteurs d'accès qui devra être donc validé,
    - nombre de participants,
    - événements, fermetures exceptionnelles, etc.
- gestion fine des droits utilisateurs et des actions associées: 
    - peut ouvrir un lieu de pratique,
    - peut agir au nom du club,
    - niveau des utilisateurs (débutant/confirmé/ etc.),
    - etc.
- mode "membre du bureau" pouvant créer des événements, des fermetures, etc.,
- accès restreint à l'application, sur invitation seulement,
- notifications des utilisateurs.

L'application est actuellement configurée pour la **Compagnie d'Arc de Saint-Leu-la-Forêt** *i.e.* pour:
- 2 lieux de pratique: gymnase et terrain,
- 2 types d'utilisateurs: débutant et confirmé,
- charte graphique à dominante verte,
- terminologie "archerie" mais centralisée dans un fichier de localisation.

Évolutif et configurable en modifiant quelques lignes de codes/fichiers de configuration.

## Techniquement

- flutter (front),
- firebase (db + hosting),
- fcm (notifications).

Disponible actuellement en tant qu'application mobile, PWA ou site web.

| système| application mobile | PWA | site internet |
| --- | --- | --- | --- |
| Android| ✅ (Android >= 8)| ✅ (*) | ✅ |
| iOS | ❌ (à faire) | ✅ (**)| ✅ | 
| ordinateur | n.a. | ✅ | ✅ |

(*) En PWA sous Android, les notifications semblent pleinement fonctionnelles à partir d'Android 13 (à vérifier plus finement).

(**) En PWA sous iOS Les notifications nécessitent une verison iOS supérieure ou égale à la 17.5.

De plus, pour que les notifications soient opérationnelles, un serveur back est nécessaire (disponible [ici][caslf-appli-server-url]).

## Installation

### Localement

```shell
git clone https://github.com/nbarikipoulos/appli-caslf.git
cd appli-caslf
# Configuration firebase
# Nécessite un projet firebase préalablement configuré
flutterfire configure -o /lib/firebase/firebase_options.dart

# Dépendances Flutter
flutter pub get
```

Du fichier firebase_options.dart précédemment généré, copier les options pour la version web dans la variable firebaseConfig du fichier web/firebase-messaging-sw.js (*i.e.* configuration du worker de messages pour les PWA).

```js

...

const firebaseConfig = {
  apiKey: "myApiKeyHere",
  authDomain: "myAuthDomainHere",
  projectId: "myProjectIdHere",
  storageBucket: "myStorageBucketHere",
  messagingSenderId: "mymMssagingSenderIdHere",
  appId: "myAppIDHere"
};

...

```

### Lancer l'application

```shell
flutter devices
flutter run -d <device_id>
````

## Générer/Déployer


#### WWW/PWA

```shell
# générer
flutter build web --release -o $pwd/public
firebase init hosting

# déploiement (pour test)
firebase hosting:channel:deploy preprod

# déploiement (prod)
firebase deploy
```

#### Android
```shell
# apk
flutter build apk
# Play store
flutter build appbundle
```

## Projets Annexes

- Serveur de notifications disponible [ici][caslf-appli-server-url],
- Documentation utilisateur accessible [là][caslf-appli-doc-url].

## Crédits

- Nicolas Barriquand ([nbarikipoulos][nbarikipoulos-url]).

## Licence
![MIT][mit-svg]

Ce dépôt est sous licence MIT.

[caslf-appli-server-url]: https://github.com/nbarikipoulos/appli-caslf-server
[caslf-appli-doc-url]: https://github.com/nbarikipoulos/appli-caslf-doc
[nbarikipoulos-url]: https://github.com/nbarikipoulos
[mit-svg]: https://upload.wikimedia.org/wikipedia/commons/f/f8/License_icon-mit-88x31-2.svg
