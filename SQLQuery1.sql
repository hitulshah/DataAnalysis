Select*
From portfolio..NashvilleHousing

--Standardize Date Format

Select SaleDateConverted, CONVERT(date, SaleDate) 
From portfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

--Populate Property Address Data

Select*
From portfolio..NashvilleHousing
WHERE PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From portfolio..NashvilleHousing a
JOIN portfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From portfolio..NashvilleHousing a
JOIN portfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Breaking out Address

SELECT PropertyAddress
FROM portfolio..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM portfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE NashvilleHousing
add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT OwnerAddress
FROM portfolio..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)
FROM portfolio..NashvilleHousing


ALTER TABLE NashvilleHousing
add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3) 

ALTER TABLE NashvilleHousing
add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2)

ALTER TABLE NashvilleHousing
add OwnerSplitState nvarchar(255);


Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)

SELECT Distinct(SoldAsVacant)
FROM portfolio..NashvilleHousing

--Remove Duplicates

WITH RowNumCTE AS(
SELECT*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				  UniqueID
				  ) row_num
FROM portfolio..NashvilleHousing
--Order by ParcelID
)
SELECT* 
From RowNumCTE
WHERE row_num > 1
Order by PropertyAddress



--Delete Unused columns
Select*
From portfolio..NashvilleHousing

Alter Table  portfolio..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter Table  portfolio..NashvilleHousing
DROP COLUMN SaleData