/* data cleaning*/
Select * from dbo.NashvilleHousing

/*standardize date format*/
Select SaleDate, CONVERT (Date,SaleDate) from dbo.NashvilleHousing
Update NashvilleHousing
SET saledate = CONVERT (Date, SaleDate)

Alter Table NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT (Date, SaleDate)

Select SaleDateConverted, CONVERT (Date,SaleDate) from dbo.NashvilleHousing

-- Populate Property Address--

Select * from dbo.NashvilleHousing
--where PropertyAddress is NUll
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b 
ON a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b 
ON a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

-- Breaking Address into individual columns (address, city, state)
--Property Address
Select PropertyAddress from dbo.NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from dbo.NashvilleHousing

ALTER Table NashvilleHousing
ADD PropertySplitAddress NVarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER Table NashvilleHousing
ADD PropertySplitCity NVarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--Owner Address
Select OwnerAddress from dbo.NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(replace(owneraddress,',','.'),1)
from dbo.NashvilleHousing

Alter Table NashvilleHousing
ADD OwnerSplitAddress NVarChar(255);

UPDATE NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'), 3)

Alter Table NashvilleHousing
ADD OwnerSplitCity NVarChar(255);

UPDATE NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'), 2)

Alter Table NashvilleHousing
ADD OwnerSplitState NVarChar(255);

UPDATE NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'), 1)


-- Y and N to Yes and No in "Sold as Vacant"
Select DISTINCT(soldasvacant), Count(soldasvacant)
from dbo.NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' then 'Yes'
	WHEN SoldasVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END
from dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' then 'Yes'
	WHEN SoldasVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END

--Remove Duplicates
with rownumcte as (
select *, 
	ROW_NUMBER() over (
	PARTITION BY ParcelID, 
				PropertyAddress, 
				SalePrice, 
				SaleDate,
				LegalReference
				Order by 
					uniqueid
					) row_num
from dbo.NashvilleHousing)
select * from  rownumcte
where row_num > 1 
order by PropertyAddress

--delete unused columns 
select * from dbo.NashvilleHousing

Alter table dbo.nashvillehousing
drop column owneraddress, taxdistrict, propertyaddress, saledate