PASSWORD="xxx"
DESTINATION="/backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S) # Common timestamp for naming
BACKUP_NAME="backup_${TIMESTAMP}"
LOGFILE="${DESTINATION}/${BACKUP_NAME}.log"
MONGO_CONTAINER="mongo"
 
# Redirect stdout and stderr to log file
exec > "${LOGFILE}"
exec 2>&1
 
echo "Backup started at $(date)"
 
BACKUPDIR="${DESTINATION}/${BACKUP_NAME}"
echo "Backup directory ${BACKUPDIR}"
mkdir -p "${BACKUPDIR}"

# Backup MongoDB
echo "Dumping Mongo DB ..."
/usr/bin/docker exec "${MONGO_CONTAINER}" mongodump --archive > "${BACKUPDIR}"/mongodb.archive
/usr/bin/lzma -T0 "${BACKUPDIR}"/mongodb.archive
/usr/bin/openssl enc -k "${PASSWORD}" -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -salt -in  "${BACKUPDIR}"/mongodb.archive.lzma -out "${BACKUPDIR}"/mongodb.archive.lzma.enc
rm "${BACKUPDIR}"/mongodb.archive.lzma

# Delete old backups older than 14 days
find "${DESTINATION}" -maxdepth 1 -mtime +14 -type d | xargs rm -rf