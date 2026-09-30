const express = require("express");

const {
  getAllCategories,
  addCategory,
  updateCategory,
  deleteCategory,
  updateCategoryStatus,
} = require("../controllers/categoryController");

const router = express.Router();

router.get("/", getAllCategories);

router.post("/", addCategory);

router.put("/:id", updateCategory);

router.delete("/:id", deleteCategory);

router.put("/:id/status", updateCategoryStatus);

module.exports = router;