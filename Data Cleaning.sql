SELECT * 
FROM Project3..NashvilleHousing

--Time column cleaning (breaking Time and Date)

SELECT SaleDate, CONVERT(Date,SaleDate) as DateofSale
FROM Project3..NashvilleHousing

ALTER TABLE Project3..NashvilleHousing
ADD DateofSale Date

UPDATE Project3..NashvilleHousing
SET DateofSale = CONVERT(Date,SaleDate)

ALTER TABLE Project3..NashvilleHousing
DROP COLUMN SaleDate

--Populating prioperty addresses

SELECT PropertyAddress
FROM Project3..NashvilleHousing
WHERE PropertyAddress is null

SELECT COUNT([UniqueID ]), PropertyAddress	--All null addresses have unique identities
FROM Project3..NashvilleHousing
WHERE PropertyAddress is null
GROUP BY PropertyAddress

SELECT N.ParcelID, N.PropertyAddress, V.ParcelID, V.PropertyAddress, ISNULL(N.PropertyAddress, V.PropertyAddress)
FROM Project3..NashvilleHousing N
JOIN Project3..NashvilleHousing V
	ON N.ParcelID = V.ParcelID
	AND N.[UniqueID ] <> V.[UniqueID ]
WHERE N.PropertyAddress is null

UPDATE N
SET PropertyAddress = ISNULL(N.PropertyAddress, V.PropertyAddress)
FROM Project3..NashvilleHousing N
JOIN Project3..NashvilleHousing V
	ON N.ParcelID = V.ParcelID
	AND N.[UniqueID ] <> V.[UniqueID ]
WHERE N.PropertyAddress is null

--Address Column Cleaning (breaking Address, City, State)

SELECT PropertyAddress, OwnerAddress
FROM Project3..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM Project3..NashvilleHousing

ALTER TABLE Project3..NashvilleHousing
ADD PropertyAddressSplit NVARCHAR(255)

UPDATE Project3..NashvilleHousing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Project3..NashvilleHousing
ADD PropertyAddressCity NVARCHAR(255)

UPDATE Project3..NashvilleHousing
SET PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

ALTER TABLE Project3..NashvilleHousing
DROP COLUMN PropertyAddress



SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerAddressSplit, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OwnerCity, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OwnerState
FROM Project3..NashvilleHousing

ALTER TABLE Project3..NashvilleHousing
ADD OwnerAddressSplit NVARCHAR(255)

UPDATE Project3..NashvilleHousing
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Project3..NashvilleHousing
ADD OwnerCity NVARCHAR(255)

UPDATE Project3..NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Project3..NashvilleHousing
ADD OwnerState NVARCHAR(255)

UPDATE Project3..NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

ALTER TABLE Project3..NashvilleHousing
DROP COLUMN OwnerAddress

--Changing Strings in rows (y/n to yes/no)

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM Project3..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, REPLACE(SoldAsVacant, 'Y', 'Yes')
FROM Project3..NashvilleHousing
WHERE SoldAsVacant = 'Y'
SELECT SoldAsVacant, REPLACE(SoldAsVacant, 'N', 'No')
FROM Project3..NashvilleHousing
WHERE SoldAsVacant = 'N'

UPDATE Project3..NashvilleHousing
SET 
SoldAsVacant = REPLACE(SoldAsVacant, 'Y', 'Yes')
WHERE SoldAsVacant = 'Y'

UPDATE Project3..NashvilleHousing
SET 
SoldAsVacant = REPLACE(SoldAsVacant, 'N', 'No')
WHERE SoldAsVacant = 'N'

--OR

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Project3..NashvilleHousing

--Removing duplicates

WITH RowNumCTE as(
SELECT *, ROW_NUMBER() OVER (
			PARTITION BY ParcelID, PropertyAddressSplit, SalePrice, DateofSale, LegalReference
			ORDER BY UniqueID
			)row_num
FROM Project3..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

SELECT *
FROM Project3..NashvilleHousing

--Deleting unused columns



--Analysing data for fun

SELECT SalePrice, LandUse, LandValue
FROM Project3..NashvilleHousing
ORDER BY 1

SELECT OwnerName, SUM(SalePrice) as TotalValueOwned
FROM Project3..NashvilleHousing
GROUP BY OwnerName

SELECT OwnerName, SalePrice			--validating results
FROM Project3..NashvilleHousing
--WHERE Ownername LIKE 'HLAD, JOHN%'
--WHERE Ownername LIKE 'Carter, Becky M.'
--WHERE Ownername LIKE 'Foy, Laura A.'
WHERE Ownername LIKE 'SAIN, SARA'


SELECT COUNT([UniqueID ]) as NumberofBuildings, LandUse
FROM Project3..NashvilleHousing
GROUP BY LandUse
ORDER BY 1