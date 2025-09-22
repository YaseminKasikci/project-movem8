// mongo-init.js
db = db.getSiblingDB('admin');

db.createUser({
  user: 'movem8_app',
  pwd: 'Mov3m8!Mongo-2025',
  roles: [
    { role: 'readWrite', db: 'movem8' },
    { role: 'dbAdmin', db: 'movem8' }
  ]
});