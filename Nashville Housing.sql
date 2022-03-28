------------- DATA CLEANING PROJECT --------------

---- Change Sale Date Format to Remove Time

ALTER TABLE HousingNashville
ALTER COLUMN SaleDate Date;

---- Fill in Null Property Addresses Using ParcelID

SELECT *
FROM PortfolioProject..HousingNashville
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

--Create a Self Join
SELECT fir.ParcelID, fir.PropertyAddress, sec.ParcelID, sec.PropertyAddress, ISNULL(fir.PropertyAddress, sec.PropertyAddress)
FROM PortfolioProject..HousingNashville fir
JOIN PortfolioProject..HousingNashville sec
	ON fir.ParcelID = sec.ParcelID
	AND fir.[UniqueID] <> sec.[UniqueID]
WHERE fir.PropertyAddress IS  NULL;

--Update Null Properties in Table
UPDATE fir
SET PropertyAddress = ISNULL(fir.PropertyAddress, sec.PropertyAddress)
FROM PortfolioProject..HousingNashville fir
JOIN PortfolioProject..HousingNashville sec
	ON fir.ParcelID = sec.ParcelID
	AND fir.[UniqueID] <> sec.[UniqueID]
WHERE fir.PropertyAddress IS NULL;

---- Separate Property Address

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address
FROM PortfolioProject..HousingNashville

--Update Table and Add Columns for Street Address and City
ALTER TABLE HousingNashville
ADD PropertyStreetName Nvarchar(255);

ALTER TABLE HousingNashville
ADD PropertyCityName Nvarchar(255);

UPDATE HousingNashville
SET PropertyStreetName = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

UPDATE HousingNashville
SET PropertyCityName = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));

---- Separate Owner Address (Using Different Method)

SELECT OwnerAddress
FROM PortfolioProject..HousingNashville;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) AS StreetName
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) AS City
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) AS State
FROM PortfolioProject..HousingNashville;

--Update Table and Add Columns

ALTER TABLE HousingNashville
ADD OwnerStreetName Nvarchar(255);

ALTER TABLE HousingNashville
ADD OwnerCityName Nvarchar(255);

ALTER TABLE HousingNashville
ADD OwnerStateName Nvarchar(255);

UPDATE HousingNashville
SET OwnerStreetName = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

UPDATE HousingNashville
SET OwnerCityName = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

UPDATE HousingNashville
SET OwnerStateName = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

---- Change Y and N to Yes/No in SoldAsVacant

SELECT DISTINCT(SoldAsVacant)
FROM PortfolioProject..HousingNashville;

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject..HousingNashville;

UPDATE HousingNashville
Set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

---- Remove Duplicate Rows

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
FROM PortfolioProject..HousingNashville
--ORDER BY ParcelID;
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress;

---- Delete Unused Columns

ALTER TABLE PortfolioProject..HousingNashville
DROP COLUMN PropertyAddress, TaxDistrict, OwnerAddress


SELECT *
FROM PortfolioProject..HousingNashville;

