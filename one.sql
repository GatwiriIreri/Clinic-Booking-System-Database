-- Clinic Booking System Database
-- A comprehensive MySQL database for managing clinic operations including
-- patients, doctors, appointments, medical records, and billing.

CREATE DATABASE clinicBookingSystem;

USE clinicbookingSystem;

-- Users and Authentication

-- User Roles Table
CREATE TABLE roles (
    roleId INT AUTO_INCREMENT PRIMARY KEY,
    roleName VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT 'Stores user roles like admin, doctor, nurse, receptionist, patient';

-- Users table - base table for all system users
CREATE TABLE users (
    userId INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    passwordHash VARCHAR(255) NOT NULL,
    roleId INT NOT NULL,
    isActive BOOLEAN DEFAULT TRUE,
    lastLogin DATETIME,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (roleId) REFERENCES roles (roleId)
) COMMENT 'Central users table for authentication and access control';

-- Personal Information
-- Person table - base table for patients, doctors, and staff
CREATE TABLE persons (
    personId INT AUTO_INCREMENT PRIMARY KEY,
    userId INT UNIQUE,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    dateOfBirth DATE NOT NULL,
    gender ENUM(
        'Male',
        'Female',
        'Other',
        'Prefer not to say'
    ) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    addressLine1 VARCHAR(100) NOT NULL,
    addressLine2 VARCHAR(100),
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postalCode VARCHAR(20) NOT NULL,
    country VARCHAR(50) NOT NULL DEFAULT 'United States',
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE SET NULL,
    INDEX idx_person_name (lastName, firstName)
) COMMENT 'Base personal information table for all individuals in the system';

-- Medical Specialities and staff
-- Medical specialties
CREATE TABLE specialties (
    specialtyId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT 'Medical specialties like cardiology,surgeons, dermatology, etc.';

-- Doctors table
CREATE TABLE doctors (
    doctorId INT AUTO_INCREMENT PRIMARY KEY,
    personId INT NOT NULL UNIQUE,
    licenseNumber VARCHAR(50) NOT NULL UNIQUE,
    specialtyId INT NOT NULL,
    qualification TEXT NOT NULL,
    biography TEXT,
    consultationFee DECIMAL(10, 2) NOT NULL,
    yearsOfExperience INT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (personId) REFERENCES persons (personId) ON DELETE CASCADE,
    FOREIGN KEY (specialtyId) REFERENCES specialties (specialtyId),
    INDEX idx_doctorSpecialty (specialtyId)
) COMMENT 'Information specific to doctors';

-- Staff members (nurses, receptionists, etc.)
CREATE TABLE staff (
    staffId INT AUTO_INCREMENT PRIMARY KEY,
    personId INT NOT NULL UNIQUE,
    position VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL,
    hireDate DATE NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (personId) REFERENCES persons (personId) ON DELETE CASCADE,
    INDEX idx_staffDepartment (department)
) COMMENT 'other staff members information(Apart from practitioners)';

-- Patient Information
-- Patients table
CREATE TABLE patients (
    patientId INT AUTO_INCREMENT PRIMARY KEY,
    personId INT NOT NULL UNIQUE,
    bloodType ENUM(
        'A+',
        'A-',
        'B+',
        'B-',
        'AB+',
        'AB-',
        'O+',
        'O-',
        'Unknown'
    ) DEFAULT 'Unknown',
    height DECIMAL(5, 2) COMMENT 'Height in cm',
    weight DECIMAL(5, 2) COMMENT 'Weight in kg',
    emergencyContactName VARCHAR(100),
    emergencyContactPhone VARCHAR(20),
    emergencyContactRelation VARCHAR(50),
    insuranceProvider VARCHAR(100),
    insurancePolicyNumber VARCHAR(100),
    insuranceExpiryDate DATE,
    registeredDate DATE NOT NULL DEFAULT(CURRENT_DATE),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (personId) REFERENCES persons (personId) ON DELETE CASCADE
) COMMENT 'Patient-specific information';

-- Patient allergies
CREATE TABLE allergies (
    allergyId INT AUTO_INCREMENT PRIMARY KEY,
    patientId INT NOT NULL,
    allergyName VARCHAR(100) NOT NULL,
    severity ENUM(
        'Mild',
        'Moderate',
        'Severe',
        'Life-threatening'
    ) NOT NULL,
    reaction TEXT,
    diagnosedDate DATE,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patientId) REFERENCES patients (patientId) ON DELETE CASCADE,
    UNIQUE KEY uniquePatientAllergy (patientId, allergyName)
) COMMENT 'Records patient allergies';

-- Patient medical history
CREATE TABLE medicalHistory (
    historyId INT AUTO_INCREMENT PRIMARY KEY,
    patientId INT NOT NULL,
    conditionName VARCHAR(100) NOT NULL,
    diagnosisDate DATE,
    treatmentSummary TEXT,
    isChronic BOOLEAN DEFAULT FALSE,
    notes TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patientId) REFERENCES patients (patientId) ON DELETE CASCADE,
    INDEX idx_medicalHistoryPatient (patientId)
) COMMENT 'Records patient medical history';

-- Scheduling and Appointments

-- Doctor schedules
CREATE TABLE doctorSchedules (
    scheduleId INT AUTO_INCREMENT PRIMARY KEY,
    doctorId INT NOT NULL,
    dayOfWeek ENUM(
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
    ) NOT NULL,
    startTime TIME NOT NULL,
    endTime TIME NOT NULL,
    isAvailable BOOLEAN DEFAULT TRUE,
    maxAppointments INT DEFAULT 20,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (doctorId) REFERENCES doctors (doctorId) ON DELETE CASCADE,
    UNIQUE KEY uniqueDoctorSchedule (
        doctorId,
        dayOfWeek,
        startTime
    ),
    CHECK (endTime > startTime)
) COMMENT 'Regular working schedule of doctors';

-- Doctor time off
CREATE TABLE doctorTimeOff (
    timeOffId INT AUTO_INCREMENT PRIMARY KEY,
    doctorId INT NOT NULL,
    startDatetime DATETIME NOT NULL,
    endDatetime DATETIME NOT NULL,
    reason VARCHAR(255),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (doctorId) REFERENCES doctors (doctorId) ON DELETE CASCADE,
    CHECK (endDatetime > startDatetime)
) COMMENT 'Records vacation, sick leave, and other time off for doctors';

-- Appointment status
CREATE TABLE appointmentStatuses (
    statusId INT AUTO_INCREMENT PRIMARY KEY,
    statusName VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT 'Appointment statuses like scheduled, completed, cancelled, etc.';

-- Appointment types
CREATE TABLE appointmentTypes (
    typeId INT AUTO_INCREMENT PRIMARY KEY,
    typeName VARCHAR(100) NOT NULL UNIQUE,
    defaultDuration INT NOT NULL COMMENT 'Duration in minutes',
    description TEXT,
    colorCode VARCHAR(7) COMMENT 'HEX color code for calendar display',
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT 'Types of appointments such as consultation, follow-up, procedure, etc.';

-- Appointments
CREATE TABLE appointments (
    appointmentId INT AUTO_INCREMENT PRIMARY KEY,
    patientId INT NOT NULL,
    doctorId INT NOT NULL,
    typeId INT NOT NULL,
    statusId INT NOT NULL,
    appointmentDatetime DATETIME NOT NULL,
    endDatetime DATETIME NOT NULL,
    reason TEXT NOT NULL,
    notes TEXT,
    createdBy INT NOT NULL COMMENT 'User ID who created this appointment',
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patientId) REFERENCES patients (patientId),
    FOREIGN KEY (doctorId) REFERENCES doctors (doctorId),
    FOREIGN KEY (typeId) REFERENCES appointmentTypes (typeId),
    FOREIGN KEY (statusId) REFERENCES appointmentStatuses (statusId),
    FOREIGN KEY (createdBy) REFERENCES users (userId),
    INDEX idx_appointmentDatetime (appointmentDatetime),
    INDEX idx_appointmentPatient (patientId),
    INDEX idx_appointmentDoctor (doctorId),
    CHECK (
        endDatetime > appointmentDatetime
    )
) COMMENT 'Patient appointments with doctors';

-- MEDICAL RECORDS

-- Vital signs
CREATE TABLE vitalSigns (
    vitalId INT AUTO_INCREMENT PRIMARY KEY,
    appointmentId INT NOT NULL,
    temperature DECIMAL(4, 1) COMMENT 'In Celsius',
    heartRate INT COMMENT 'BPM',
    bloodPressureSystolic INT,
    bloodPressureDiastolic INT,
    respiratoryRate INT COMMENT 'Breaths per minute',
    oxygenSaturation INT COMMENT 'SpO2 percentage',
    height DECIMAL(5, 2) COMMENT 'In cm',
    weight DECIMAL(5, 2) COMMENT 'In kg',
    recordedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    recordedBy INT NOT NULL COMMENT 'Staff ID who recorded vitals',
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (appointmentId) REFERENCES appointments (appointmentId),
    FOREIGN KEY (recordedBy) REFERENCES users (userId)
) COMMENT 'Patient vital sign measurements';

-- Medical consultations/visits
CREATE TABLE consultations (
    consultationId INT AUTO_INCREMENT PRIMARY KEY,
    appointmentId INT NOT NULL UNIQUE,
    patientId INT NOT NULL,
    doctorId INT NOT NULL,
    chiefComplaint TEXT NOT NULL,
    symptoms TEXT,
    diagnosis TEXT,
    treatmentPlan TEXT,
    followUpNeeded BOOLEAN DEFAULT FALSE,
    followUpInstructions TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (appointmentId) REFERENCES appointments (appointmentId),
    FOREIGN KEY (patientId) REFERENCES patients (patientId),
    FOREIGN KEY (doctorId) REFERENCES doctors (doctorId),
    INDEX idx_consultationPatient (patientId)
) COMMENT 'Detailed consultation records';

-- Prescriptions
CREATE TABLE medications (
    medicationId INT AUTO_INCREMENT PRIMARY KEY,
    medicationName VARCHAR(100) NOT NULL,
    genericName VARCHAR(100),
    medicationClass VARCHAR(100),
    form ENUM(
        'Tablet',
        'Capsule',
        'Liquid',
        'Injection',
        'Topical',
        'Other'
    ) NOT NULL,
    strength VARCHAR(50) NOT NULL,
    manufacturer VARCHAR(100),
    description TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uniqueMedication (
        medicationName,
        strength,
        form
    )
) COMMENT 'Medication reference catalog';

-- Prescriptions
CREATE TABLE prescriptions (
    prescriptionId INT AUTO_INCREMENT PRIMARY KEY,
    consultationId INT NOT NULL,
    patientId INT NOT NULL,
    doctorId INT NOT NULL,
    issueDate DATE NOT NULL DEFAULT(CURRENT_DATE),
    isActive BOOLEAN DEFAULT TRUE,
    notes TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (consultationId) REFERENCES consultations (consultationId),
    FOREIGN KEY (patientId) REFERENCES patients (patientId),
    FOREIGN KEY (doctorId) REFERENCES doctors (doctorId),
    INDEX idx_prescriptionPatient (patientId)
) COMMENT 'Prescription header information';

-- Prescription items (medications prescribed)
CREATE TABLE prescriptionItems (
    itemId INT AUTO_INCREMENT PRIMARY KEY,
    prescriptionId INT NOT NULL,
    medicationId INT NOT NULL,
    dosage VARCHAR(100) NOT NULL,
    frequency VARCHAR(100) NOT NULL,
    duration VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    refills INT DEFAULT 0,
    specialInstructions TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (prescriptionId) REFERENCES prescriptions (prescriptionId) ON DELETE CASCADE,
    FOREIGN KEY (medicationId) REFERENCES medications (medicationId),
    UNIQUE KEY unique_prescriptionMedication (prescriptionId, medicationId)
) COMMENT 'Details of medications in a prescription';

-- Lab test catalog
CREATE TABLE labTests (
    testId INT AUTO_INCREMENT PRIMARY KEY,
    testName VARCHAR(100) NOT NULL UNIQUE,
    testCode VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    preparationInstructions TEXT,
    normalRange TEXT,
    price DECIMAL(10, 2) NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT 'Catalog of available lab tests';

-- Lab orders
CREATE TABLE labOrders (
    orderId INT AUTO_INCREMENT PRIMARY KEY,
    patientId INT NOT NULL,
    doctorId INT NOT NULL,
    consultationId INT,
    orderDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM(
        'Ordered',
        'Collected',
        'Processing',
        'Completed',
        'Cancelled'
    ) NOT NULL DEFAULT 'Ordered',
    priority ENUM('Routine', 'Urgent', 'STAT') NOT NULL DEFAULT 'Routine',
    notes TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patientId) REFERENCES patients (patientId),
    FOREIGN KEY (doctorId) REFERENCES doctors (doctorId),
    FOREIGN KEY (consultationId) REFERENCES consultations (consultationId),
    INDEX idx_labOrderPatient (patientId),
    INDEX idx_labOrderStatus (status)
) COMMENT 'Lab test orders for patients';

-- Lab order items
CREATE TABLE labOrderItems (
    itemId INT AUTO_INCREMENT PRIMARY KEY,
    orderId INT NOT NULL,
    testId INT NOT NULL,
    status ENUM(
        'Pending',
        'Collected',
        'Processing',
        'Completed',
        'Cancelled'
    ) NOT NULL DEFAULT 'Pending',
    result TEXT,
    resultDate DATETIME,
    referenceRange TEXT,
    isAbnormal BOOLEAN,
    technicianNotes TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (orderId) REFERENCES labOrders (orderId) ON DELETE CASCADE,
    FOREIGN KEY (testId) REFERENCES labTests (testId),
    UNIQUE KEY unique_orderTest (orderId, testId)
) COMMENT 'Individual tests within a lab order';

-- Billing and Payments

-- Service catalog (procedures, consultations, etc.)
CREATE TABLE services (
    serviceId INT AUTO_INCREMENT PRIMARY KEY,
    serviceName VARCHAR(100) NOT NULL UNIQUE,
    serviceCode VARCHAR(50) NOT NULL UNIQUE,
    category VARCHAR(100) NOT NULL,
    description TEXT,
    defaultPrice DECIMAL(10, 2) NOT NULL,
    durationMinutes INT COMMENT 'Estimated duration in minutes',
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_serviceCategory (category)
) COMMENT 'Catalog of services provided by the clinic';

-- Invoice status
CREATE TABLE invoiceStatuses (
    statusId INT AUTO_INCREMENT PRIMARY KEY,
    statusName VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT 'Invoice statuses like draft, issued, paid, overdue, etc.';

-- Invoices
CREATE TABLE invoices (
    invoiceId INT AUTO_INCREMENT PRIMARY KEY,
    patientId INT NOT NULL,
    appointmentId INT,
    invoiceNumber VARCHAR(20) NOT NULL UNIQUE,
    statusId INT NOT NULL,
    issueDate DATE NOT NULL DEFAULT(CURRENT_DATE),
    dueDate DATE NOT NULL,
    totalAmount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    discountAmount DECIMAL(10, 2) DEFAULT 0,
    taxAmount DECIMAL(10, 2) DEFAULT 0,
    paymentNotes TEXT,
    createdBy INT NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patientId) REFERENCES patients (patientId),
    FOREIGN KEY (appointmentId) REFERENCES appointments (appointmentId),
    FOREIGN KEY (statusId) REFERENCES invoiceStatuses (statusId),
    FOREIGN KEY (createdBy) REFERENCES users (userId),
    INDEX idx_invoicePatient (patientId),
    INDEX idx_invoiceStatus (statusId),
    CHECK (dueDate >= issueDate)
) COMMENT 'Patient invoices';

-- Invoice items
CREATE TABLE invoiceItems (
    itemId INT AUTO_INCREMENT PRIMARY KEY,
    invoiceId INT NOT NULL,
    serviceId INT,
    description VARCHAR(255) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unitPrice DECIMAL(10, 2) NOT NULL,
    discountPercentage DECIMAL(5, 2) DEFAULT 0,
    taxPercentage DECIMAL(5, 2) DEFAULT 0,
    lineTotal DECIMAL(10, 2) GENERATED ALWAYS AS (
        quantity * unitPrice * (1 - discountPercentage / 100) * (1 + taxPercentage / 100)
    ) STORED,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (invoiceId) REFERENCES invoices (invoiceId) ON DELETE CASCADE,
    FOREIGN KEY (serviceId) REFERENCES services (serviceId)
) COMMENT 'Line items in an invoice';

-- Payment methods
CREATE TABLE paymentMethods (
    methodId INT AUTO_INCREMENT PRIMARY KEY,
    methodName VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    isActive BOOLEAN DEFAULT TRUE,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT 'Payment methods like cash, credit card, insurance, etc.';

-- Payments
CREATE TABLE payments (
    paymentId INT AUTO_INCREMENT PRIMARY KEY,
    invoiceId INT NOT NULL,
    methodId INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    paymentDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    transactionReference VARCHAR(100),
    paymentNotes TEXT,
    receivedBy INT NOT NULL COMMENT 'User ID who received the payment',
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (invoiceId) REFERENCES invoices (invoiceId),
    FOREIGN KEY (methodId) REFERENCES paymentMethods (methodId),
    FOREIGN KEY (receivedBy) REFERENCES users (userId),
    INDEX idx_paymentInvoice (invoiceId)
) COMMENT 'Payments made against invoices';

-- Insurance claims
CREATE TABLE insuranceClaims (
    claimId INT AUTO_INCREMENT PRIMARY KEY,
    invoiceId INT NOT NULL,
    patientId INT NOT NULL,
    insuranceProvider VARCHAR(100) NOT NULL,
    policyNumber VARCHAR(100) NOT NULL,
    claimNumber VARCHAR(100),
    submissionDate DATE NOT NULL DEFAULT(CURRENT_DATE),
    claimAmount DECIMAL(10, 2) NOT NULL,
    approvedAmount DECIMAL(10, 2),
    status ENUM(
        'Submitted',
        'In Process',
        'Approved',
        'Partially Approved',
        'Denied',
        'Appealed'
    ) DEFAULT 'Submitted',
    denialReason TEXT,
    responseDate DATE,
    notes TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (invoiceId) REFERENCES invoices (invoiceId),
    FOREIGN KEY (patientId) REFERENCES patients (patientId),
    INDEX idx_claimPatient (patientId),
    INDEX idx_claimStatus (status)
) COMMENT 'Insurance claims filed for patient invoices';

-- Audit and Logging
-- Activity logs
CREATE TABLE activityLogs (
    logId INT AUTO_INCREMENT PRIMARY KEY,
    userId INT,
    activityType VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    entityType VARCHAR(50) COMMENT 'The type of entity being accessed',
    entityId INT COMMENT 'The ID of the entity being accessed',
    ipAddress VARCHAR(45),
    userAgent TEXT,
    occurredAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE SET NULL,
    INDEX idx_logUser (userId),
    INDEX idx_logActivity (activityType),
    INDEX idx_logEntity (entityType, entityId),
    INDEX idx_logTime (occurredAt)
) COMMENT 'Audit trail of system activities';

-- Notifications
-- Notification types
CREATE TABLE notificationTypes (
    typeId INT AUTO_INCREMENT PRIMARY KEY,
    typeName VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    isActive BOOLEAN DEFAULT TRUE,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT 'Types of notifications like appointment reminder, lab result, etc.';

-- Notifications
CREATE TABLE notifications (
    notificationId INT AUTO_INCREMENT PRIMARY KEY,
    typeId INT NOT NULL,
    userId INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    isRead BOOLEAN DEFAULT FALSE,
    sentAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    readAt TIMESTAMP,
    relatedEntityType VARCHAR(50) COMMENT 'Type of entity this notification relates to',
    relatedEntityId INT COMMENT 'ID of entity this notification relates to',
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (typeId) REFERENCES notificationTypes (typeId),
    FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE,
    INDEX idx_notificationUser (userId),
    INDEX idx_notificationRead (isRead),
    INDEX idx_notificationEntity (
        relatedEntityType,
        relatedEntityId
    )
) COMMENT 'System notifications for users';

-- Insert roles
INSERT INTO
    roles (roleName, description)
VALUES (
        'Admin',
        'System administrator with full access'
    ),
    (
        'Doctor',
        'Medical practitioner who sees patients'
    ),
    (
        'Nurse',
        'Medical staff who assists doctors and patients'
    ),
    (
        'Receptionist',
        'Front desk staff handling appointments and billing'
    ),
    (
        'Patient',
        'Regular patient users'
    ),
    (
        'Lab Technician',
        'Staff who perform lab tests'
    );

-- Insert users
INSERT INTO
    users (
        username,
        email,
        passwordHash,
        roleId
    )
VALUES (
        'admin1',
        'admin@clinic.com',
        '$2a$10$xJwL5v5Jz5U5Z5Z5Z5Z5Z.',
        1
    ), -- Password: admin123
    (
        'dr_smith',
        'dr.smith@clinic.com',
        '$2a$10$xJwL5v5Jz5U5Z5Z5Z5Z5Z.',
        2
    ),
    (
        'dr_jones',
        'dr.jones@clinic.com',
        '$2a$10$xJwL5v5Jz5U5Z5Z5Z5Z5Z.',
        2
    ),
    (
        'nurse_amy',
        'nurse.amy@clinic.com',
        '$2a$10$xJwL5v5Jz5U5Z5Z5Z5Z5Z.',
        3
    ),
    (
        'reception1',
        'reception@clinic.com',
        '$2a$10$xJwL5v5Jz5U5Z5Z5Z5Z5Z.',
        4
    ),
    (
        'patient1',
        'john.doe@email.com',
        '$2a$10$xJwL5v5Jz5U5Z5Z5Z5Z5Z.',
        5
    ),
    (
        'patient2',
        'jane.smith@email.com',
        '$2a$10$xJwL5v5Jz5U5Z5Z5Z5Z5Z.',
        5
    ),
    (
        'lab_tech1',
        'lab.tech@clinic.com',
        '$2a$10$xJwL5v5Jz5U5Z5Z5Z5Z5Z.',
        6
    );

-- Insert persons
INSERT INTO
    persons (
        userId,
        firstName,
        lastName,
        dateOfBirth,
        gender,
        phone,
        addressLine1,
        city,
        state,
        postalCode
    )
VALUES (
        1,
        'System',
        'Admin',
        '1980-01-01',
        'Male',
        '555-0101',
        '123 Admin St',
        'Sfield',
        'IL',
        '62701'
    ),
    (
        2,
        'Robert',
        'Smith',
        '1975-05-15',
        'Male',
        '555-0202',
        '456 Oak Ave',
        'Sfield',
        'IL',
        '62702'
    ),
    (
        3,
        'Jennifer',
        'Jones',
        '1982-08-22',
        'Female',
        '555-0303',
        '789 Pine Rd',
        'Sfield',
        'IL',
        '62703'
    ),
    (
        4,
        'Amy',
        'Johnson',
        '1990-03-10',
        'Female',
        '555-0404',
        '321 Elm St',
        'Sfield',
        'IL',
        '62704'
    ),
    (
        5,
        'Michael',
        'Brown',
        '1988-11-05',
        'Male',
        '555-0505',
        '654 Maple Dr',
        'Sfield',
        'IL',
        '62705'
    ),
    (
        6,
        'John',
        'Doe',
        '1985-07-20',
        'Male',
        '555-0606',
        '987 Cedar Ln',
        'Sfield',
        'IL',
        '62706'
    ),
    (
        7,
        'Jane',
        'Smith',
        '1992-09-15',
        'Female',
        '555-0707',
        '246 Birch Blvd',
        'Sfield',
        'IL',
        '62707'
    ),
    (
        8,
        'David',
        'Wilson',
        '1987-04-18',
        'Male',
        '555-0808',
        '135 Spruce Way',
        'Sfield',
        'IL',
        '62708'
    );

-- Insert specialties
INSERT INTO
    specialties (name, description)
VALUES (
        'Cardiology',
        'Heart and cardiovascular system specialist'
    ),
    (
        'Dermatology',
        'Skin, hair, and nail specialist'
    ),
    (
        'General Practice',
        'Primary care physician'
    ),
    (
        'Neurology',
        'Nervous system specialist'
    ),
    (
        'Pediatrics',
        'Child healthcare specialist'
    );

-- Insert doctors
INSERT INTO
    doctors (
        personId,
        licenseNumber,
        specialtyId,
        qualification,
        biography,
        consultationFee,
        yearsOfExperience
    )
VALUES (
        2,
        'MD123456',
        1,
        'MD, Cardiology Fellowship',
        'Dr. Smith has over 15 years of experience in cardiology.',
        200.00,
        15
    ),
    (
        3,
        'MD654321',
        3,
        'MD, Family Medicine',
        'Dr. Jones is a board-certified family physician.',
        150.00,
        10
    );

-- Insert staff
INSERT INTO
    staff (
        personId,
        position,
        department,
        hireDate
    )
VALUES (
        4,
        'Registered Nurse',
        'Clinical',
        '2018-06-15'
    ),
    (
        5,
        'Receptionist',
        'Administration',
        '2020-02-10'
    ),
    (
        8,
        'Lab Technician',
        'Laboratory',
        '2019-09-22'
    );

-- Insert patients
INSERT INTO
    patients (
        personId,
        bloodType,
        height,
        weight,
        emergencyContactName,
        emergencyContactPhone,
        emergencyContactRelation,
        insuranceProvider,
        insurancePolicyNumber,
        insuranceExpiryDate
    )
VALUES (
        6,
        'A+',
        175.5,
        80.2,
        'Mary Doe',
        '555-1111',
        'Spouse',
        'Blue Cross',
        'BC123456789',
        '2024-12-31'
    ),
    (
        7,
        'O-',
        162.0,
        58.5,
        'Robert Smith',
        '555-2222',
        'Father',
        'Aetna',
        'AE987654321',
        '2024-10-15'
    );

-- Insert allergies
INSERT INTO
    allergies (
        patientId,
        allergyName,
        severity,
        reaction,
        diagnosedDate
    )
VALUES (
        1,
        'Penicillin',
        'Severe',
        'Hives and difficulty breathing',
        '2015-03-10'
    ),
    (
        2,
        'Peanuts',
        'Life-threatening',
        'Anaphylaxis',
        '2010-05-22'
    );

-- Insert medical history
INSERT INTO
    medicalHistory (
        patientId,
        conditionName,
        diagnosisDate,
        treatmentSummary,
        isChronic
    )
VALUES (
        1,
        'Hypertension',
        '2018-07-15',
        'Controlled with medication',
        TRUE
    ),
    (
        1,
        'Type 2 Diabetes',
        '2019-02-20',
        'Diet and exercise management',
        TRUE
    ),
    (
        2,
        'Asthma',
        '2015-11-05',
        'Inhaler as needed',
        TRUE
    );

-- Insert doctor schedules
INSERT INTO
    doctorSchedules (
        doctorId,
        dayOfWeek,
        startTime,
        endTime,
        maxAppointments
    )
VALUES (
        1,
        'Monday',
        '09:00:00',
        '17:00:00',
        16
    ),
    (
        1,
        'Wednesday',
        '09:00:00',
        '17:00:00',
        16
    ),
    (
        1,
        'Friday',
        '09:00:00',
        '17:00:00',
        16
    ),
    (
        2,
        'Tuesday',
        '08:00:00',
        '16:00:00',
        16
    ),
    (
        2,
        'Thursday',
        '08:00:00',
        '16:00:00',
        16
    ),
    (
        2,
        'Saturday',
        '10:00:00',
        '14:00:00',
        8
    );

-- Insert appointment statuses
INSERT INTO
    appointmentStatuses (statusName, description)
VALUES (
        'Scheduled',
        'Appointment is booked but not yet occurred'
    ),
    (
        'Completed',
        'Appointment has been completed'
    ),
    (
        'Cancelled',
        'Appointment was cancelled'
    ),
    (
        'No-Show',
        'Patient did not attend the appointment'
    );

-- Insert appointment types
INSERT INTO
    appointmentTypes (
        typeName,
        defaultDuration,
        description,
        colorCode
    )
VALUES (
        'Initial Consultation',
        30,
        'First visit with a doctor',
        '#4287f5'
    ),
    (
        'Follow-up Visit',
        15,
        'Follow-up appointment',
        '#42f5a7'
    ),
    (
        'Annual Physical',
        45,
        'Comprehensive yearly checkup',
        '#f54242'
    ),
    (
        'Procedure',
        60,
        'Medical procedure or treatment',
        '#f5d142'
    );

-- Insert appointments
INSERT INTO
    appointments (
        patientId,
        doctorId,
        typeId,
        statusId,
        appointmentDatetime,
        endDatetime,
        reason,
        notes,
        createdBy
    )
VALUES (
        1,
        1,
        1,
        2,
        '2023-06-01 10:00:00',
        '2023-06-01 10:30:00',
        'Annual checkup',
        'Patient requested full blood work',
        5
    ),
    (
        2,
        2,
        2,
        1,
        '2023-06-15 11:00:00',
        '2023-06-15 11:15:00',
        'Follow-up on medication',
        'Check effectiveness of new prescription',
        5
    ),
    (
        1,
        1,
        3,
        1,
        '2023-07-10 09:00:00',
        '2023-07-10 09:45:00',
        'Annual physical exam',
        '',
        5
    );

-- Insert vital signs
INSERT INTO
    vitalSigns (
        appointmentId,
        temperature,
        heartRate,
        bloodPressureSystolic,
        bloodPressureDiastolic,
        respiratoryRate,
        oxygenSaturation,
        height,
        weight,
        recordedBy
    )
VALUES (
        1,
        36.8,
        72,
        120,
        80,
        16,
        98,
        175.5,
        80.2,
        4
    );

-- Insert consultations
INSERT INTO
    consultations (
        appointmentId,
        patientId,
        doctorId,
        chiefComplaint,
        symptoms,
        diagnosis,
        treatmentPlan,
        followUpNeeded
    )
VALUES (
        1,
        1,
        1,
        'Routine checkup',
        'None reported',
        'Healthy',
        'Continue current lifestyle',
        FALSE
    );

-- Insert prescriptions
INSERT INTO
    prescriptions (
        consultationId,
        patientId,
        doctorId,
        notes
    )
VALUES (
        1,
        1,
        1,
        'Take with food in the evening'
    );

-- Insert lab tests
INSERT INTO
    labTests (
        testName,
        testCode,
        description,
        preparationInstructions,
        normalRange,
        price
    )
VALUES (
        'Complete Blood Count',
        'CBC',
        'Measures various components of blood',
        'Fasting not required',
        'Varies by component',
        75.00
    ),
    (
        'Lipid Panel',
        'LIPID',
        'Measures cholesterol and triglycerides',
        'Fast for 12 hours',
        'Total cholesterol < 200 mg/dL',
        120.00
    ),
    (
        'Hemoglobin A1C',
        'A1C',
        'Measures average blood sugar over 3 months',
        'Fasting not required',
        '4.8-5.6%',
        85.00
    );

-- Insert lab orders
INSERT INTO
    labOrders (
        patientId,
        doctorId,
        consultationId,
        status,
        priority
    )
VALUES (
        1,
        1,
        1,
        'Completed',
        'Routine'
    );

-- Insert services
INSERT INTO
    services (
        serviceName,
        serviceCode,
        category,
        description,
        defaultPrice,
        durationMinutes
    )
VALUES (
        'Initial Consultation',
        'CON-INIT',
        'Consultation',
        'First visit with a specialist',
        200.00,
        30
    ),
    (
        'Follow-up Visit',
        'CON-FU',
        'Consultation',
        'Follow-up appointment',
        150.00,
        15
    ),
    (
        'Annual Physical',
        'EXAM-ANNUAL',
        'Examination',
        'Comprehensive yearly checkup',
        250.00,
        45
    ),
    (
        'Complete Blood Count',
        'LAB-CBC',
        'Laboratory',
        'Blood test measuring various components',
        75.00,
        NULL
    ),
    (
        'Lipid Panel',
        'LAB-LIPID',
        'Laboratory',
        'Cholesterol and triglycerides test',
        120.00,
        NULL
    );

-- Insert invoice statuses
INSERT INTO
    invoiceStatuses (statusName, description)
VALUES (
        'Draft',
        'Invoice has not been finalized'
    ),
    (
        'Issued',
        'Invoice has been sent to patient'
    ),
    (
        'Paid',
        'Invoice has been fully paid'
    ),
    (
        'Overdue',
        'Invoice is past due date'
    ),
    (
        'Cancelled',
        'Invoice was cancelled'
    );

-- Insert payment methods
INSERT INTO
    paymentMethods (methodName, description)
VALUES (
        'Cash',
        'Physical cash payment'
    ),
    (
        'Credit Card',
        'Visa, Mastercard, etc.'
    ),
    (
        'Debit Card',
        'Bank debit card'
    ),
    (
        'Insurance',
        'Payment through insurance'
    ),
    (
        'Check',
        'Personal or bank check'
    );

-- Insert notification types
INSERT INTO
    notificationTypes (typeName, description)
VALUES (
        'Appointment Reminder',
        'Reminder for upcoming appointments'
    ),
    (
        'Lab Results Ready',
        'Notification when lab results are available'
    ),
    (
        'Payment Received',
        'Confirmation of payment received'
    ),
    (
        'Prescription Ready',
        'Notification when prescription is ready'
    );