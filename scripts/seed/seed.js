/**
 * One-time Firestore + Firebase Auth seed script for Assistly Pro.
 *
 * Populates all 6 collections (users, employees, employee_time_logs,
 * clients, client_payments, operating_expenses) with the same demo
 * data the Flutter app's Mock Repositories use, plus creates the one
 * default Manager/Admin login account.
 *
 * SAFE TO RE-RUN: every Firestore document uses a fixed, deterministic
 * ID (matching the Mock data's own IDs), so re-running this script
 * OVERWRITES existing documents with the same values rather than
 * creating duplicates. The Auth-user step also checks for an existing
 * account by email before attempting to create one, so it won't error
 * out on a second run either.
 *
 * Usage (from scripts/seed/):
 *   node seed.js
 */
// Source - https://stackoverflow.com/a/64699729
// Posted by riversun
// Retrieved 2026-07-19, License - CC BY-SA 4.0


const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');


admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const auth = admin.auth();

// ---------------------------------------------------------------------
// Config — change these before running if you want a different admin
// login. This is the ONLY account this script creates (per project
// requirement: "Manager/Admin login only").
// ---------------------------------------------------------------------
const ADMIN_EMAIL = 'admin@assistlypro.com';
const ADMIN_PASSWORD = 'AssistlyPro#2026';
const ADMIN_DISPLAY_NAME = 'Assistly Pro Admin';

function timestamp(dateString) {
  return admin.firestore.Timestamp.fromDate(new Date(dateString));
}

// ---------------------------------------------------------------------
// 1. Admin / Manager account (Firebase Auth + users/{uid} document)
// ---------------------------------------------------------------------
async function seedAdminUser() {
  let userRecord;
  try {
    userRecord = await auth.createUser({
      email: ADMIN_EMAIL,
      password: ADMIN_PASSWORD,
      displayName: ADMIN_DISPLAY_NAME,
    });
    console.log(`Created Auth user: ${ADMIN_EMAIL}`);
  } catch (error) {
    if (error.code === 'auth/email-already-exists') {
      userRecord = await auth.getUserByEmail(ADMIN_EMAIL);
      console.log(`Auth user already exists, reusing: ${ADMIN_EMAIL}`);
    } else {
      throw error;
    }
  }

  const now = timestamp('2026-07-18');
  await db.collection('users').doc(userRecord.uid).set({
    uid: userRecord.uid,
    email: ADMIN_EMAIL,
    displayName: ADMIN_DISPLAY_NAME,
    role: 'Manager',
    status: 'Active',
    createdAt: now,
    updatedAt: now,
  });
  console.log('Seeded users/' + userRecord.uid);
}

// ---------------------------------------------------------------------
// 2. Employees — identical records to MockEmployeeRepository's seed.
// ---------------------------------------------------------------------
const employees = [
  { employeeId: 'EMP001', fullName: 'John Smith', email: 'john.smith@assistlypro.com', contactNumber: '09171234501', position: 'Virtual Assistant', hourlyRate: 180, status: 'Active', department: 'Operations', supervisor: 'Robert Tan', assignedClient: 'CLI001', dateHired: '2026-01-15' },
  { employeeId: 'EMP002', fullName: 'Maria Santos', email: 'maria.santos@assistlypro.com', contactNumber: '09171234502', position: 'Customer Support Specialist', hourlyRate: 165, status: 'Active', department: 'Human Resources', supervisor: 'Jane Smith', assignedClient: 'CLI002', dateHired: '2026-01-20' },
  { employeeId: 'EMP003', fullName: 'Michael Reyes', email: 'michael.reyes@assistlypro.com', contactNumber: '09171234503', position: 'Bookkeeper', hourlyRate: 200, status: 'Active', department: 'Finance', supervisor: 'Robert Tan', assignedClient: null, dateHired: '2026-02-01' },
  { employeeId: 'EMP004', fullName: 'Angela Cruz', email: 'angela.cruz@assistlypro.com', contactNumber: '09171234504', position: 'Social Media Manager', hourlyRate: 175, status: 'Active', department: 'Marketing', supervisor: 'Kevin Lee', assignedClient: 'CLI003', dateHired: '2026-02-10' },
  { employeeId: 'EMP005', fullName: 'Daniel Garcia', email: 'daniel.garcia@assistlypro.com', contactNumber: '09171234505', position: 'Graphic Designer', hourlyRate: 190, status: 'Active', department: 'Marketing', supervisor: 'Kevin Lee', assignedClient: 'CLI001', dateHired: '2026-03-01' },
  { employeeId: 'EMP006', fullName: 'Patricia Lim', email: 'patricia.lim@assistlypro.com', contactNumber: '09171234506', position: 'Data Entry Specialist', hourlyRate: 150, status: 'Inactive', department: 'Human Resources', supervisor: 'Jane Smith', assignedClient: null, dateHired: '2026-01-05' },
  { employeeId: 'EMP007', fullName: 'Robert Tan', email: 'robert.tan@assistlypro.com', contactNumber: '09171234507', position: 'Executive Assistant', hourlyRate: 210, status: 'Active', department: 'Operations', supervisor: 'Jane Smith', assignedClient: null, dateHired: '2026-03-15' },
  { employeeId: 'EMP008', fullName: 'Sophia Dela Cruz', email: 'sophia.delacruz@assistlypro.com', contactNumber: '09171234508', position: 'Content Writer', hourlyRate: 170, status: 'Inactive', department: 'Marketing', supervisor: 'Kevin Lee', assignedClient: null, dateHired: '2026-02-20' },
];

async function seedEmployees() {
  const batch = db.batch();
  for (const emp of employees) {
    const createdAt = timestamp(emp.dateHired);
    const ref = db.collection('employees').doc(emp.employeeId);
    batch.set(ref, {
      employeeId: emp.employeeId,
      fullName: emp.fullName,
      email: emp.email,
      contactNumber: emp.contactNumber,
      department: emp.department,
      position: emp.position,
      supervisor: emp.supervisor,
      assignedClient: emp.assignedClient,
      hourlyRate: emp.hourlyRate,
      dateHired: timestamp(emp.dateHired),
      status: emp.status,
      createdAt,
      updatedAt: createdAt,
    });
  }
  await batch.commit();
  console.log(`Seeded ${employees.length} employees.`);
}

// ---------------------------------------------------------------------
// 3. Employee Time Logs — reproduces the EXACT same generation logic
//    as MockEmployeeRepository._seedHours() in the Flutter app (same
//    weekday list, same rotation-per-employee pattern), so the numbers
//    here match the Mock data exactly, not just approximately.
// ---------------------------------------------------------------------
const WEEKDAYS = ['2026-06-22', '2026-06-23', '2026-06-24', '2026-06-25', '2026-06-26', '2026-06-29', '2026-06-30', '2026-07-01', '2026-07-02', '2026-07-03'];
const BASE_PATTERN = [8, 7.5, 8, 6, 8, 8, 7, 8, 8, 6.5];
const HOURS_ROTATIONS = { EMP001: 0, EMP002: 2, EMP003: 4, EMP004: 1, EMP005: 3, EMP007: 5 };

async function seedTimeLogs() {
  let counter = 1;
  const batch = db.batch();

  for (const [employeeId, rotation] of Object.entries(HOURS_ROTATIONS)) {
    for (let i = 0; i < WEEKDAYS.length; i++) {
      const hoursWorked = BASE_PATTERN[(i + rotation) % BASE_PATTERN.length];
      const timeLogId = 'HR' + String(counter).padStart(3, '0');
      const now = timestamp(WEEKDAYS[i]);
      const ref = db.collection('employee_time_logs').doc(timeLogId);
      batch.set(ref, {
        timeLogId,
        employeeId,
        workDate: timestamp(WEEKDAYS[i]),
        hoursWorked,
        remarks: null,
        createdAt: now,
        updatedAt: now,
      });
      counter++;
    }
  }
  // 60 records total — well under Firestore's 500-operation batch
  // limit, so a single commit is fine here.
  await batch.commit();
  console.log(`Seeded ${counter - 1} employee time logs.`);
}

// ---------------------------------------------------------------------
// 4. Clients — identical records to MockClientRepository's seed,
//    except `serviceType` replaces the retired `monthlyPayment` field
//    (see the migration inconsistency notes — monthlyPayment has no
//    home in the new schema).
// ---------------------------------------------------------------------
const clients = [
  { clientId: 'CLI001', companyName: 'ABC Retail Corp', contactPerson: 'Michael Cruz', email: 'abc@retailcorp.com', contactNumber: '09221234501', serviceType: 'Full-Service Virtual Assistance', status: 'Active', createdAt: '2026-01-10' },
  { clientId: 'CLI002', companyName: 'Bright Ideas Marketing', contactPerson: 'Jenny Uy', email: 'jenny@brightideas.com', contactNumber: '09221234502', serviceType: 'Social Media Management', status: 'Active', createdAt: '2026-01-25' },
  { clientId: 'CLI003', companyName: 'Solid Rock Realty', contactPerson: 'Mark Villanueva', email: 'mark@solidrockrealty.com', contactNumber: '09221234503', serviceType: 'Administrative Support', status: 'Active', createdAt: '2026-02-05' },
  { clientId: 'CLI004', companyName: 'Fresh Bites Café', contactPerson: 'Karen Ong', email: 'karen@freshbites.com', contactNumber: '09221234504', serviceType: 'Bookkeeping Services', status: 'Inactive', createdAt: '2026-01-05' },
  { clientId: 'CLI005', companyName: 'Nova Tech Solutions', contactPerson: 'Paul Mendoza', email: 'paul@novatech.com', contactNumber: '09221234505', serviceType: 'Full-Service Virtual Assistance', status: 'Active', createdAt: '2026-03-01' },
  { clientId: 'CLI006', companyName: 'Golden Gate Logistics', contactPerson: 'Ella Ramos', email: 'ella@goldengate.com', contactNumber: '09221234506', serviceType: 'Customer Support Outsourcing', status: 'Inactive', createdAt: '2026-02-15' },
];

async function seedClients() {
  const batch = db.batch();
  for (const client of clients) {
    const createdAt = timestamp(client.createdAt);
    const ref = db.collection('clients').doc(client.clientId);
    batch.set(ref, {
      clientId: client.clientId,
      companyName: client.companyName,
      contactPerson: client.contactPerson,
      email: client.email,
      contactNumber: client.contactNumber,
      serviceType: client.serviceType,
      status: client.status,
      createdAt,
      updatedAt: createdAt,
    });
  }
  await batch.commit();
  console.log(`Seeded ${clients.length} clients.`);
}

// ---------------------------------------------------------------------
// 5. Client Payments — identical records to MockClientRepository's
//    seed (3 months × the 4 clients that were active at seed time).
// ---------------------------------------------------------------------
const PAYMENT_DATES = ['2026-05-01', '2026-06-01', '2026-07-01'];
const PAYMENT_AMOUNTS = { CLI001: 50000, CLI002: 35000, CLI003: 42000, CLI005: 60000 };

async function seedPayments() {
  let counter = 1;
  const batch = db.batch();
  for (const [clientId, amount] of Object.entries(PAYMENT_AMOUNTS)) {
    for (const date of PAYMENT_DATES) {
      const paymentId = 'PAY' + String(counter).padStart(3, '0');
      const now = timestamp(date);
      const ref = db.collection('client_payments').doc(paymentId);
      batch.set(ref, {
        paymentId,
        clientId,
        paymentDate: timestamp(date),
        amount,
        remarks: null,
        createdAt: now,
        updatedAt: now,
      });
      counter++;
    }
  }
  await batch.commit();
  console.log(`Seeded ${counter - 1} client payments.`);
}

// ---------------------------------------------------------------------
// 6. Operating Expenses — one document per month. No Mock Repository
//    equivalent exists (the old Settings model used percentages, not
//    monthly dollar figures), so these are new, clean demo values.
// ---------------------------------------------------------------------
const operatingExpenses = [
  { month: '2026-05', toolsExpense: 5000, miscellaneousExpense: 1500 },
  { month: '2026-06', toolsExpense: 5000, miscellaneousExpense: 1500 },
  { month: '2026-07', toolsExpense: 5000, miscellaneousExpense: 1500 },
];

async function seedOperatingExpenses() {
  const batch = db.batch();
  for (const expense of operatingExpenses) {
    const expenseId = 'EXP-' + expense.month;
    const now = timestamp(expense.month + '-01');
    const ref = db.collection('operating_expenses').doc(expenseId);
    batch.set(ref, {
      expenseId,
      month: expense.month,
      toolsExpense: expense.toolsExpense,
      miscellaneousExpense: expense.miscellaneousExpense,
      remarks: null,
      createdAt: now,
      updatedAt: now,
    });
  }
  await batch.commit();
  console.log(`Seeded ${operatingExpenses.length} operating expense records.`);
}

// ---------------------------------------------------------------------
// Run everything in order
// ---------------------------------------------------------------------
async function main() {
  console.log('Seeding Assistly Pro Firestore data...\n');
  await seedAdminUser();
  await seedEmployees();
  await seedTimeLogs();
  await seedClients();
  await seedPayments();
  await seedOperatingExpenses();
  console.log('\nDone. You can now log in with:');
  console.log(`  Email:    ${ADMIN_EMAIL}`);
  console.log(`  Password: ${ADMIN_PASSWORD}`);
  console.log('\nChange this password after first login (Firebase Console > Authentication > Users).');
  process.exit(0);
}

main().catch((error) => {
  console.error('Seeding failed:', error);
  process.exit(1);
});
