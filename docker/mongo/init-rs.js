// Initiate the 3-member replica set (idempotent).
try {
  rs.status();
  print("replica set already initiated");
} catch (e) {
  rs.initiate({
    _id: "rs-ridelink",
    members: [
      { _id: 0, host: "mongo1:27017", priority: 2 },
      { _id: 1, host: "mongo2:27017", priority: 1 },
      { _id: 2, host: "mongo3:27017", priority: 1 }
    ]
  });
  // wait until a primary is elected so the next script can create collections
  while (!db.hello().isWritablePrimary) { sleep(500); }
  print("replica set initiated, primary elected");
}
