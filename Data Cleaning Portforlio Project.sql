/*
	CLEANING DATA IN SQL

*/

select *
From dataCleaning.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------

-- Standadized Date Format

select SaleDate, CONVERT(date, SaleDate)
From dataCleaning.dbo.NashvilleHousing

--this command update didn't work
--Update NashvilleHousing
--Set SaleDate = Convert(Date, saleDate)

--so we have to create a new column "saleDateConverted" and add the converted saleDate to it

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert(Date, saleDate)

select SaleDateConverted
From dataCleaning.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------

--POPULATE PROPERTY ADDRESS DATA

select *
From dataCleaning.dbo.NashvilleHousing
--Where propertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULl(a.PropertyAddress, b.PropertyAddress)
From dataCleaning.dbo.NashvilleHousing a
JOIN dataCleaning.dbo.NashvilleHousing b
 ON a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
 --where a.PropertyAddress is null

Update a
SET propertyAddress = ISNULl(a.PropertyAddress, b.PropertyAddress)
From dataCleaning.dbo.NashvilleHousing a
JOIN dataCleaning.dbo.NashvilleHousing b
	 ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------------

-- BRAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

select PropertyAddress
From dataCleaning.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as city
FROM dataCleaning.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add propertyMainAddress Nvarchar(225);

Update NashvilleHousing
SET propertyMainAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add propertyCityAddress Nvarchar(225);

Update NashvilleHousing
SET propertyCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



select *
From dataCleaning.dbo.NashvilleHousing


--spliting owners address


select OwnerAddress
From dataCleaning.dbo.NashvilleHousing


select 
PARSENAME(Replace(ownerAddress, ',', '.'), 3)
,PARSENAME(Replace(ownerAddress, ',', '.'), 2)
,PARSENAME(Replace(ownerAddress, ',', '.'), 1)
From dataCleaning.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerMainAddress Nvarchar(225);

Update NashvilleHousing
SET OwnerMainAddress = PARSENAME(Replace(ownerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerCityAddress Nvarchar(225);

Update NashvilleHousing
SET OwnerCityAddress = PARSENAME(Replace(ownerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerStateAddress Nvarchar(225);

Update NashvilleHousing
SET OwnerStateAddress = PARSENAME(Replace(ownerAddress, ',', '.'), 1)

select OwnerMainAddress, OwnerCityAddress, OwnerStateAddress
From dataCleaning.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------------------

--CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD

select Distinct(SoldAsVacant), count(soldasvacant)
From dataCleaning.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
  END
From dataCleaning.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant =
   CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant 
   END



------------------------------------------------------------------------------------------------------------------


---REMOVE DUPLICATES


WITH RowNumCTE AS(
select *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num


From dataCleaning.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
order by PropertyAddress



-----------------------------------------------------------------------------------------------------------------------------

--DELETE UNUSED COLUMNS




Select *
From dataCleaning.dbo.NashvilleHousing

ALTER TABLE dataCleaning.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE dataCleaning.dbo.NashvilleHousing
DROP COLUMN SaleDate


