// Synthetic MongoDB data (TEST DATA ONLY). Run after 01_collections.js.
// mongosh mongodb://localhost:27017 mongo/02_seed.js
const dbr = db.getSiblingDB("ridelink");
const rnd = (a, b) => a + Math.random() * (b - a);
const point = () => ({ type: "Point", coordinates: [rnd(-8.65, -8.55), rnd(41.12, 41.19)] });

// live state of 200 drivers (ids match PostgreSQL 2001..2200)
dbr.driver_live_state.deleteMany({});
dbr.driver_live_state.insertMany(Array.from({ length: 200 }, (_, i) => ({
  _id: 2001 + i,
  status: Math.random() < 0.7 ? "AVAILABLE" : "ON_TRIP",
  categoryId: 1 + (i % 4),
  loc: point(),
  updatedAt: new Date()
})));

// 20 000 GPS pings over the last 2 hours
const now = Date.now();
dbr.driver_locations.insertMany(Array.from({ length: 20000 }, () => ({
  ts: new Date(now - rnd(0, 2 * 3600 * 1000)),
  meta: { driverId: 2001 + Math.floor(Math.random() * 200), tripId: null },
  loc: point(), speedKmh: Math.round(rnd(0, 70)), heading: Math.round(rnd(0, 359))
})));

// reviews (2 000, one per (trip, fromUser) pair) and some chat/tickets
dbr.reviews.insertMany(Array.from({ length: 2000 }, (_, i) => ({
  tripId: NumberLong(i + 1), fromUserId: 1 + (i % 2000), toUserId: 2001 + (i % 200),
  stars: NumberInt(1 + Math.floor(Math.random() * 5)),
  tags: Math.random() < 0.5 ? ["clean_car"] : ["polite", "on_time"],
  comment: "Test review " + i, createdAt: new Date(now - rnd(0, 30 * 86400000))
})));
dbr.trip_messages.insertMany(Array.from({ length: 500 }, (_, i) => ({
  tripId: NumberLong(1 + (i % 100)), from: i % 2 ? "driver" : "rider", text: "msg " + i, sentAt: new Date()
})));
dbr.support_tickets.insertMany(Array.from({ length: 50 }, (_, i) => ({
  userId: 1 + i, tripId: NumberLong(1 + i), category: "LOST_ITEM", status: i % 3 ? "OPEN" : "CLOSED",
  thread: [{ author: "rider", text: "Forgot my phone", ts: new Date() }], attachments: []
})));
print("seed done: live=" + dbr.driver_live_state.countDocuments() +
      " pings=" + dbr.driver_locations.countDocuments() + " reviews=" + dbr.reviews.countDocuments());
