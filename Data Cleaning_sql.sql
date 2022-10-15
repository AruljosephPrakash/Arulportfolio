SELECT *
FROM Portfolio_project.dbo.housing

--Standardize date format--
SELECT Saledateconverted,CONVERT(Date,Saledate)
FROM Portfolio_project.dbo.housing

UPDATE housing
SET Saledate = CONVERT(Date,Saledate)

ALTER TABLE housing
Add Saledateconverted Date;

UPDATE housing
SET Saledateconverted = CONVERT(Date,Saledate)

-----------------------------------------------------------------------

--Populate Property address data--
SELECT *
FROM Portfolio_project.dbo.housing
--where PropertyAddress is null--
ORDER BY Parcelid

SELECT a.Parcelid,a.PropertyAddress,b.Parcelid,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio_project.dbo.housing a
JOIN Portfolio_project.dbo.housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio_project.dbo.housing a
JOIN Portfolio_project.dbo.housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------------------------------
--Braking address into Induvidual columns(Address,City,State)--
SELECT 
	 as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address

FROM Portfolio_project.dbo.housing

ALTER TABLE housing
Add PropertysplitAddress Nvarchar(200);

UPDATE housing
SET PropertysplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE housing
Add Propertycity Nvarchar(200);

UPDATE housing
SET Propertycity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

-------------------------------------------------------------------------------------------------------------------

--Split Owner address usiong Parsename----

Select
PARSENAME(REPLACE(OwnerAddress,',','.') , 3)
,PARSENAME(REPLACE(OwnerAddress,',','.') , 2)
,PARSENAME(REPLACE(OwnerAddress,',','.') , 1)

FROM Portfolio_project.dbo.housing

ALTER TABLE housing
Add OwnersplitAddress Nvarchar(200);

UPDATE housing
SET OwnersplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') , 3)

ALTER TABLE housing
Add Ownercity Nvarchar(200);

UPDATE housing
SET Ownercity = PARSENAME(REPLACE(OwnerAddress,',','.') , 2)

ALTER TABLE housing
Add Ownerstate Nvarchar(200);

UPDATE housing
SET Ownerstate = PARSENAME(REPLACE(OwnerAddress,',','.') , 1)

-------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant " field--

SELECT DISTINCT(SoldAsVacant),Count(SoldAsVacant)
FROM Portfolio_project.dbo.housing
Group by SoldAsVacant
order by 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN'Yes'
       WHEN SoldAsVacant = 'N' THEN'No'
	   ELSE SoldAsVacant
	   END
FROM Portfolio_project.dbo.housing


UPDATE housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN'Yes'		
       WHEN SoldAsVacant = 'N' THEN'No'
	   ELSE SoldAsVacant
	   END
------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates--
WITH RownumCTE AS(
SELECT *,
	 ROW_NUMBER() OVER(
 PARTITION BY ParcelID,
              PropertyAddress,
			  Saledate,
			  Saleprice,
			  LegalReference
			  ORDER BY
				Uniqueid
				)row_num

FROM Portfolio_project.dbo.housing
--ORDER BY ParcelID--
)
SELECT * 
FROM RownumCTE
WHERE row_num > 1
--Order by PropertyAddress--

-------------------------------------------------------------------------------------------------------------
--Delete Unused Columns--
SELECT *
FROM Portfolio_project.dbo.housing

ALTER TABLE Portfolio_project.dbo.housing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE Portfolio_project.dbo.housing
DROP COLUMN SaleDate