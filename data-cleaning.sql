/*
	Cleaning data in SQL
*/

SELECT *
FROM [Nashville Housing]
---------------------------------------------------------------------------------------
-- Standardize date format

SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM [Nashville Housing]

UPDATE [Nashville Housing]
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE [Nashville Housing]
ADD SaleDateConverted DATE;

UPDATE [Nashville Housing]
SET SaleDateConverted = CONVERT(DATE, SaleDate)

SELECT SaleDateConverted
FROM [Nashville Housing]

---------------------------------------------------------------------------------------
-- Populate property address

SELECT PropertyAddress
FROM [Nashville Housing]

SELECT *
FROM [Nashville Housing]
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville Housing] a
JOIN [Nashville Housing] b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS Null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville Housing] a
JOIN [Nashville Housing] b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS Null

---------------------------------------------------------------------------------------
-- Breaking out address into individual columns (Address, City, State)

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) Address,
	   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) City
FROM [Nashville Housing]

ALTER TABLE [Nashville Housing]
ADD Address VARCHAR(255)

UPDATE [Nashville Housing]
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [Nashville Housing]
ADD City VARCHAR(255)

UPDATE [Nashville Housing]
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

SELECT *
FROM [Nashville Housing]

SELECT 
	PARSENAME( REPLACE(OwnerAddress, ',','.'), 3) Address,
	PARSENAME( REPLACE(OwnerAddress, ',','.'), 2) City ,
	PARSENAME( REPLACE(OwnerAddress, ',','.'), 1) State
FROM [Nashville Housing]

ALTER TABLE [Nashville Housing]
ADD OwnerSplitAddress VARCHAR(255)

UPDATE [Nashville Housing]
SET OwnerSplitAddress = PARSENAME( REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitCity VARCHAR(255)

UPDATE [Nashville Housing]
SET OwnerSplitCity = PARSENAME( REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitState VARCHAR(255)

UPDATE [Nashville Housing]
SET OwnerSplitState = PARSENAME( REPLACE(OwnerAddress, ',','.'), 1)

SELECT *
FROM [Nashville Housing]

---------------------------------------------------------------------------------------
-- Change 0 and 1 to No and Yes in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Nashville Housing]
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant)

SELECT SoldAsVacant, 
	CASE 
		WHEN SoldAsVacant = 0 THEN 'No'
		WHEN SoldAsVacant = 1 THEN 'Yes'
	END
FROM [Nashville Housing]

ALTER TABLE [Nashville Housing]
ALTER COLUMN SoldAsVacant VARCHAR(50)

UPDATE [Nashville Housing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 0 THEN 'No' WHEN SoldAsVacant = 1 THEN 'Yes' END

Select SoldAsVacant
FROM [Nashville Housing]


---------------------------------------------------------------------------------------
-- Rename columns

EXEC sp_rename '[Nashville Housing].Address' , 'PropertySplitAddress', 'COLUMN';
EXEC sp_rename '[Nashville Housing].City' , 'PropertySplitCity', 'COLUMN';

---------------------------------------------------------------------------------------
-- Remove duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) row_num
FROM [Nashville Housing]
)

SELECT * 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

---------------------------------------------------------------------------------------
-- DELETE Unused columns

Select *
From [Nashville Housing]


ALTER TABLE [Nashville Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



