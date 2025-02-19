const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const dotenv = require("dotenv");
const crypto = require('crypto'); // Add this line
const sendEmail = require('./utils/sendEmail');
const generateOTP = () => Math.floor(100000 + Math.random() * 900000).toString();

dotenv.config();

const app = express();
app.use(express.json());
// Add this after initializing express app
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
const mongoURI = process.env.MONGO_URI || "mongodb+srv://langlens:22cs004_22cs011@cluster0.15a9r.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

mongoose.connect(mongoURI, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log("✅ MongoDB Connected"))
  .catch(err => console.log("❌ MongoDB Error:", err));


// User Schema
const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  resetToken: { type: String }, // For password reset
  resetPasswordOTP: String,
  resetPasswordExpire: Date
});


const User = mongoose.model("User", UserSchema);

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use((req, res, next) => {
  console.log(`Received ${req.method} request for: ${req.url}`);
  next();
});
const verifyToken = (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1]; // Extract token from "Bearer <token>"
  if (!token) {
    return res.status(401).json({ message: "Access denied. No token provided." });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = decoded.userId; // Attach user ID to the request object
    next();
  } catch (err) {
    return res.status(401).json({ message: "Invalid token." });
  }
};
// 🔹 SIGNUP Route
app.post("/signup", async (req, res) => {
  const { name, email, password } = req.body;

  try {
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: "Email already exists. Please log in." });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const newUser = new User({ name, email, password: hashedPassword });
    await newUser.save();

    const token = jwt.sign({ userId: newUser._id }, process.env.JWT_SECRET, { expiresIn: '1h' });

    res.status(201).json({ 
      message: "User created successfully",
      token,
      name: newUser.name,
      email: newUser.email
    });
  } catch (err) {
    console.error("Signup error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

// 🔹 LOGIN Route
app.post("/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: "User not found. Please sign up first." });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid credentials. Try again." });
    }

    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, { expiresIn: '1h' });

    res.status(200).json({ 
      message: "Login successful",
      token,
      name: user.name,
      email: user.email
    });
  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

// 🔹 FORGOT PASSWORD Route
// Add OTP generator utility


// Updated User Schema

app.post("/forgotpassword", async (req, res) => {
  try {
    const user = await User.findOne({ email: req.body.email });
    if (!user) return res.status(404).json({ message: "User not found" });

    const otp = generateOTP();
    user.resetPasswordOTP = otp;
    user.resetPasswordExpire = Date.now() + 600000; // 10 minutes
    await user.save();

    const message = `Your OTP is: ${otp}\nValid for 10 minutes.`;

    await sendEmail({
      email: user.email,
      subject: 'Password Reset OTP',
      message
    });

    res.status(200).json({ success: true, message: 'OTP sent' });
  } catch (err) {
    console.error("Forgot password error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

// New OTP Verification Route
// In server.js
app.post("/verify-otp", async (req, res) => {
  console.log('📨 OTP Verification Request Received:', {
    email: req.body.email,
    otp: req.body.otp,
    time: new Date().toISOString()
  });

  try {
    const user = await User.findOne({ 
      email: req.body.email,
      resetPasswordExpire: { $gt: Date.now() }
    });

    console.log('🔍 Database Query Result:', user ? 'User found' : 'User not found');

    if (!user || user.resetPasswordOTP !== req.body.otp) {
      console.log('❌ Invalid OTP Attempt');
      return res.status(400).json({ message: 'Invalid OTP or OTP expired' });
    }

    console.log('✅ OTP Verified Successfully');
    res.status(200).json({ success: true });
  } catch (err) {
    console.error('🔥 Server Error:', err);
    res.status(500).json({ error: "Internal server error" });
  }
});

// Updated Reset Password Route
app.post("/resetpassword", async (req, res) => {
  try {
    const { email, otp, password } = req.body;
    const user = await User.findOne({ 
      email,
      resetPasswordOTP: otp,
      resetPasswordExpire: { $gt: Date.now() }
    });

    if (!user) {
      return res.status(400).json({ message: 'Invalid OTP or OTP expired' });
    }

    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(password, salt);
    user.resetPasswordOTP = undefined;
    user.resetPasswordExpire = undefined;
    await user.save();

    res.status(200).json({ success: true, message: 'Password updated successfully' });
  } catch (err) {
    console.error("Reset password error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});
// 🔹 DELETE Account Route
app.delete("/user/delete", verifyToken, async (req, res) => {
  try {
    const userId = req.userId; // Extracted from the token in verifyToken middleware

    // Find and delete the user
    const deletedUser = await User.findByIdAndDelete(userId);
    if (!deletedUser) {
      return res.status(404).json({ message: "User not found." });
    }

    res.status(200).json({ message: "Account deleted successfully" });
  } catch (err) {
    console.error("Delete account error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});
// 🔹 CHANGE PASSWORD Route
app.post("/user/change-password", verifyToken, async (req, res) => {
  const { oldPassword, newPassword } = req.body;
  const userId = req.userId;

  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found." });
    }

    const isMatch = await bcrypt.compare(oldPassword, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Old password is incorrect." });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    user.password = hashedPassword;
    await user.save();

    res.status(200).json({ message: "Password updated successfully" });
  } catch (err) {
    console.error("Change password error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

// 🔹 CHANGE EMAIL Route
app.post("/user/change-email", verifyToken, async (req, res) => {
  const { newEmail, password } = req.body;
  const userId = req.userId;

  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found." });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Password is incorrect." });
    }

    const existingUser = await User.findOne({ email: newEmail });
    if (existingUser) {
      return res.status(400).json({ message: "Email already exists. Please use a different email." });
    }

    user.email = newEmail;
    await user.save();

    res.status(200).json({ message: "Email updated successfully", email: newEmail });
  } catch (err) {
    console.error("Change email error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});


const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => console.log(`🚀 Server running on port ${PORT}`));