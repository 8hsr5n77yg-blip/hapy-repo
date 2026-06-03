// MySQL-compatible datetime string: YYYY-MM-DD HH:MM:SS
function mysqlNow() {
  return new Date().toISOString().slice(0, 19).replace('T', ' ');
}

module.exports = { mysqlNow };
